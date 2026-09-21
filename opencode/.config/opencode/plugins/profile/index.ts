/**
 * profile — global in-session model-profile switcher.
 *
 * Global fallback for projects without their own `.opencode/plugins/profile`
 * (e.g. exarh-web). slovo-propovedi-mobile keeps its own project-local copy
 * of this plugin as the source of truth there — see that project's
 * `.opencode/plugins/profile/index.ts` for the full design rationale
 * (mode-based agent registry pinning, no TUI dialog, etc). This file mirrors
 * it, with four differences:
 *
 * 1. profilesDir is resolved from THIS FILE's own location (import.meta.dir),
 *    not from ctx.location.directory — a project-relative path would look
 *    for `<current project>/.opencode/profiles`, which doesn't exist for
 *    most projects when this plugin runs globally.
 * 2. setup() no-ops entirely when the current project has its own
 *    `.opencode/plugins/profile` directory. Both a global and a project-local
 *    plugin get loaded simultaneously when opencode runs inside such a
 *    project (project doesn't shadow global by id) — without this check,
 *    every command here (`/profile`, `/profile-<name>`) would register
 *    TWICE, once from each plugin, exactly the duplicate-completion-entry bug
 *    already hit and fixed once for the TUI dialog attempt.
 * 3. Which subagent ids get pinned by rewriting their .opencode/agents/<id>.md
 *    frontmatter vs. via the ctx.agent.transform registry is determined
 *    dynamically per project (does that .md file exist for ctx.location.directory?),
 *    not from a hardcoded list — unlike the mobile copy, this file runs
 *    against whichever project happens to be using it as a fallback, and
 *    different projects can have different custom-agent layouts.
 * 4. Plugin id is "profile-global", not "profile" — a global and a
 *    project-local plugin sharing one id are both flagged failed by the
 *    plugin host itself, before setup() even runs (see the id comment below).
 *
 * Model failover (adaptive fallback on quota/rate-limit errors) is ported
 * verbatim from the mobile copy's failover.ts/shared.ts. Its state/log files
 * stay project-relative (.opencode/profile-fallback.*), matching the
 * per-project agent frontmatter it rewrites, and it is mounted only after the
 * early-return guard above has decided this instance is the active one.
 */

import * as fs from "node:fs/promises"
import * as path from "node:path"
import { Plugin } from "@opencode/plugin"
import { installFailover, resolveAgentModel } from "./failover"
import {
  formatRef,
  formatValue,
  isMissingFileError,
  parseModelRef,
  toMessage,
  type ModelRef,
} from "./shared"

/** This file's own directory — .../plugins/profile — independent of the current project. */
const PLUGIN_DIR = import.meta.dir

/** Plugin-scoped storage key holding the active profile name. */
const STORAGE_KEY = "activeProfile"

/** The 7 agent slots wired from a profile file, in display order. */
const PROFILE_AGENTS = ["plan", "build", "researcher", "coder", "explore", "scribe", "reviewer"] as const

/**
 * Ids of PROFILE_AGENTS that are true subagents — everything except the
 * primary pair (plan/build), which must stay unpinned so
 * ctx.session.switchModel remains the sole, immediate switch mechanism for
 * them (opencode always prefers an agent's own configured model over the
 * session's live one, so pinning a primary would permanently defeat
 * switchModel for it). Which of these get pinned via frontmatter rewrite
 * vs. the registry transform is decided per-project at runtime — see
 * classifySubagents.
 */
const SUBAGENT_IDS = new Set<string>(PROFILE_AGENTS.filter((id) => id !== "plan" && id !== "build"))

interface ProfileData {
  primary: ModelRef
  agents: Record<string, ModelRef>
}

/** Wrap parseModelRef so malformed values carry the profile/field location. */
function parseProfileRef(name: string, fieldPath: string, raw: string): ModelRef {
  try {
    return parseModelRef(raw)
  } catch {
    throw new Error(`profile "${name}" [${fieldPath}]: expected "provider/model[#variant]", got "${raw}"`)
  }
}

/**
 * Load and parse a profile file at the boundary. Validates the shape of every
 * field and parses every model string eagerly, so callers receive a fully
 * trusted ProfileData. Throws a descriptive error naming the offending field.
 */
async function loadProfile(profilesDir: string, name: string): Promise<ProfileData> {
  const filePath = path.join(profilesDir, `${name}.json`)
  const source = await fs.readFile(filePath, "utf8")
  const parsed = JSON.parse(source) as { primary?: unknown; agents?: unknown }

  if (typeof parsed.primary !== "string") {
    throw new Error(`profile "${name}" [primary]: expected "provider/model[#variant]", got ${formatValue(parsed.primary)}`)
  }

  if (typeof parsed.agents !== "object" || !parsed.agents) {
    throw new Error(`profile "${name}" [agents]: expected an object of agent models, got ${formatValue(parsed.agents)}`)
  }

  const agents: Record<string, ModelRef> = {}
  for (const [agentId, raw] of Object.entries(parsed.agents)) {
    if (typeof raw !== "string") {
      throw new Error(
        `profile "${name}" [/agents "${agentId}"]: expected "provider/model[#variant]", got ${formatValue(raw)}`
      )
    }
    agents[agentId] = parseProfileRef(name, `/agents "${agentId}"`, raw)
  }

  return { primary: parseProfileRef(name, "primary", parsed.primary), agents }
}

/** List profile names from the profiles directory (sorted, stable ordering). */
async function listProfiles(profilesDir: string): Promise<string[]> {
  const entries = await fs.readdir(profilesDir)
  return entries
    .filter((entry) => entry.endsWith(".json"))
    .map((entry) => entry.replace(/\.json$/, ""))
    .sort()
}

/** True when the given directory exists (any type — used for the local-override check). */
async function pathExists(target: string): Promise<boolean> {
  try {
    await fs.access(target)
    return true
  } catch {
    return false
  }
}

/**
 * Split SUBAGENT_IDS into agents with their own .opencode/agents/<id>.md
 * file (pinned by rewriting that file's frontmatter) vs. built-ins with none
 * (pinned via the ctx.agent.transform registry instead, further below).
 * Computed per-project at runtime rather than hardcoded, since this file
 * runs as a fallback for whichever project has no profile plugin of its
 * own, and different projects define different custom agents.
 *
 * Rewriting frontmatter is load-bearing, not stylistic, for the first group:
 * opencode's markdown-agent loader re-applies each agent's frontmatter AFTER
 * plugin transforms run, so a ctx.agent.transform pin on one of these gets
 * silently discarded the instant it's set — confirmed empirically on the
 * slovo-propovedi-mobile copy of this plugin (a canary written into the
 * transform survived on a built-in agent but was erased on every
 * markdown-defined one). The built-in group has no such loader pass to lose
 * the pin to, so the registry transform works fine for them — and hand-
 * writing a fresh .md file to move one onto the frontmatter mechanism
 * instead would mean reconstructing its full accumulated permission set
 * from scratch, risking silently loosening it. Not worth doing for an agent
 * that already pins correctly.
 */
async function classifySubagents(
  agentsDir: string
): Promise<{ markdown: Set<string>; registry: Set<string> }> {
  const markdown = new Set<string>()
  const registry = new Set<string>()
  for (const agentId of SUBAGENT_IDS) {
    if (await pathExists(path.join(agentsDir, `${agentId}.md`))) {
      markdown.add(agentId)
    } else {
      registry.add(agentId)
    }
  }
  return { markdown, registry }
}

/**
 * Write (or update) the top-level `model:` key in a subagent's own
 * .opencode/agents/<id>.md frontmatter, leaving everything else in the file
 * byte-for-byte untouched — description, permissions, and the whole prompt
 * body. The config schema accepts the same "provider/model[#variant]" string
 * used everywhere else here (@opencode/schema's ConfigAgent.Info.model
 * union), so formatRef's output can be written directly.
 *
 * Parses frontmatter by hand (not a YAML lib) since the shape here is known
 * and simple: a fixed set of top-level scalar keys plus one indented
 * `permissions:` list. A full YAML round-trip risks silently reformatting or
 * reordering that list; this only ever touches a single top-level line.
 *
 * Returns false (no write) when the file already has the desired line.
 */
async function writeAgentModelFrontmatter(agentsDir: string, agentId: string, modelRef: ModelRef): Promise<boolean> {
  const filePath = path.join(agentsDir, `${agentId}.md`)
  const source = await fs.readFile(filePath, "utf8")
  const match = source.match(/^(---\r?\n)([\s\S]*?)(\r?\n---\r?\n)/)
  if (!match || match.index !== 0) {
    throw new Error(`agent file "${filePath}" has no frontmatter block starting at the top of the file`)
  }

  const [whole, open, body, close] = match
  const desiredLine = `model: ${formatRef(modelRef)}`
  const lines = body.split(/\r?\n/)
  const modelLineIndex = lines.findIndex((line) => /^model:\s/.test(line) || line === "model:")
  if (modelLineIndex !== -1) {
    if (lines[modelLineIndex] === desiredLine) return false
    lines[modelLineIndex] = desiredLine
  } else {
    const modeLineIndex = lines.findIndex((line) => /^mode:\s/.test(line))
    lines.splice(modeLineIndex !== -1 ? modeLineIndex + 1 : 0, 0, desiredLine)
  }

  const newSource = open + lines.join("\n") + close + source.slice(whole.length)
  if (newSource === source) return false
  await fs.writeFile(filePath, newSource, "utf8")
  return true
}

/**
 * Rewrite every markdown-defined subagent's frontmatter to match the given
 * profile, best-effort per agent (one missing/malformed file shouldn't block
 * the rest). Errors are collected and handed to the caller to report; this
 * never throws.
 */
async function applyMarkdownFrontmatterPins(
  agentsDir: string,
  profile: ProfileData,
  markdownIds: ReadonlySet<string>
): Promise<string[]> {
  const errors: string[] = []
  for (const agentId of markdownIds) {
    const modelRef = profile.agents[agentId]
    if (!modelRef) continue
    try {
      await writeAgentModelFrontmatter(agentsDir, agentId, modelRef)
    } catch (error) {
      errors.push(`${agentId}: ${error instanceof Error ? error.message : String(error)}`)
    }
  }
  return errors
}

export default Plugin.define({
  // Distinct id ("profile-global", not "profile") is load-bearing, not
  // cosmetic: two plugins sharing one id (global + project copy, both loaded
  // when opencode runs inside a project that has its own) get flagged failed
  // by the plugin host itself, BEFORE setup() even runs — confirmed
  // empirically (red "failed" duplicate in the Plugins panel, purely from the
  // id collision, present even though the early-return guard below means this
  // plugin's setup() does nothing at all in that case).
  id: "profile-global",
  async setup(ctx) {
    // Yield to a project-local profile plugin — see file header. Both would
    // otherwise load side by side and double-register every command.
    if (await pathExists(path.join(ctx.location.directory, ".opencode", "plugins", "profile"))) {
      return
    }

    const profilesDir = path.join(PLUGIN_DIR, "..", "..", "profiles")
    const agentsDir = path.join(ctx.location.directory, ".opencode", "agents")
    const storedProfile = await ctx.storage.get(STORAGE_KEY)
    const warn = (message: string): void => {
      console.warn(`[profile] ${message}`)
    }

    const { markdown: markdownSubagentIds, registry: registrySubagentIds } = await classifySubagents(agentsDir)

    // Reserved for the /profile command; the agent registry transform reads it.
    let activeProfile: ProfileData | null = null
    let activeProfileName: string | null = null

    if (typeof storedProfile === "string" && storedProfile) {
      try {
        activeProfile = await loadProfile(profilesDir, storedProfile)
        activeProfileName = storedProfile
        // Re-sync agent frontmatter with the persisted profile on every
        // startup, not just on an explicit /profile switch — the .md files
        // are the durable pin, so a plain server restart (no /profile call)
        // must still leave a markdown-defined subagent on the right model.
        const errors = await applyMarkdownFrontmatterPins(agentsDir, activeProfile, markdownSubagentIds)
        if (errors.length > 0) {
          warn(`profile "${storedProfile}": failed to sync agent frontmatter for ${errors.join(", ")}`)
        }
      } catch (error) {
        warn(`stored profile "${storedProfile}" could not be loaded: ${toMessage(error)} — starting with defaults`)
        if (isMissingFileError(error)) {
          await ctx.storage.remove(STORAGE_KEY)
        }
      }
    }

    // Failover is mounted before the registry transform so a persisted overlay
    // is re-applied (and the module's overlay state recovered) before the base
    // transform below can read it via resolveAgentModel. deps.directory is the
    // CURRENT project, so the state/log files stay project-relative — failover
    // rewrites that project's agent frontmatter, so its state must be per
    // project too.
    const failover = await installFailover(ctx, {
      directory: ctx.location.directory,
      getActiveProfile: () => activeProfile,
      writeAgentModelFrontmatter: (agentId, modelRef) =>
        writeAgentModelFrontmatter(agentsDir, agentId, modelRef),
      applyProfilePins: (profile) =>
        applyMarkdownFrontmatterPins(agentsDir, profile, markdownSubagentIds),
      agentIds: PROFILE_AGENTS,
      markdownAgentIds: markdownSubagentIds,
      registryAgentIds: registrySubagentIds,
      warn,
    })

    // Only agents with no .opencode/agents/<id>.md file go through this path
    // — see classifySubagents for why: a registry pin on a markdown-defined
    // agent gets silently discarded once its own frontmatter gets
    // (re-)applied, so those are pinned via applyMarkdownFrontmatterPins
    // instead. resolveAgentModel makes the effective model overlay-aware (a
    // live failover override wins over the profile value).
    await ctx.agent.transform((editor) => {
      if (!activeProfile) return

      for (const agentId of registrySubagentIds) {
        const modelRef = resolveAgentModel(activeProfile, agentId)
        if (!modelRef) continue
        const agent = editor.get(agentId)
        if (!agent) {
          warn(`profile "${activeProfileName}" references unknown agent "${agentId}" — skipped`)
          continue
        }
        editor.update(agentId, (agent) => {
          agent.model = modelRef
        })
      }
    })

    const buildListMessage = async (): Promise<string> => {
      let names: string[]
      try {
        names = await listProfiles(profilesDir)
      } catch (error) {
        return `❌ profile plugin: cannot read ${profilesDir}: ${toMessage(error)}`
      }

      const lines = names.map((name) => {
        const marker = name === activeProfileName ? " (active)" : ""
        return `  ${name}${marker}`
      })
      return [
        "Available profiles (model combos):",
        "",
        ...lines,
        "",
        "Usage:",
        "  /profile            list profiles + active one",
        "  /profile <name>     switch to that profile (persisted across restarts)",
      ].join("\n")
    }

    const buildSummaryMessage = (name: string, frontmatterErrors: readonly string[]): string => {
      const profile = activeProfile
      if (!profile) {
        return `✅ Profile "${name}" activated. Primary and subagent models are set.`
      }
      const subagentSummary = PROFILE_AGENTS.map((agentId) => {
        const modelRef = profile.agents[agentId]
        if (!modelRef) return `    ${agentId}: (unset — skipped)`
        const via = registrySubagentIds.has(agentId)
          ? "next spawn, registry"
          : markdownSubagentIds.has(agentId)
            ? "now, frontmatter"
            : "this session only, via switchModel"
        return `    ${agentId}: ${formatRef(modelRef)} (${via})`
      }).join("\n")
      const lines = [
        `✅ Profile switched to "${name}".`,
        `  primary: ${formatRef(profile.primary)} (applied to this session now)`,
        "  subagents:",
        subagentSummary,
      ]
      if (frontmatterErrors.length > 0) {
        lines.push("", `⚠ failed to update agent frontmatter for: ${frontmatterErrors.join(", ")}`)
      }
      return lines.join("\n")
    }

    /** Shared by "/profile <name>" and each per-profile "/profile-<name>" command. */
    const applyProfileToSession = async (sessionID: string, name: string): Promise<void> => {
      let profile: ProfileData
      try {
        profile = await loadProfile(profilesDir, name)
      } catch (error) {
        let valid: string
        try {
          valid = (await listProfiles(profilesDir)).join(", ")
        } catch {
          valid = "(unavailable — profile directory unreadable)"
        }
        await ctx.session.synthetic({
          sessionID,
          text: `❌ profile "${name}" could not be loaded: ${toMessage(error)} — valid profiles: ${valid}`,
        })
        return
      }

      activeProfile = profile
      activeProfileName = name
      // A manual profile switch supersedes any failover overlay: clear it
      // (delete the state file, dispose pins, log reset) before re-applying.
      await failover.reset()
      await ctx.storage.set(STORAGE_KEY, name)
      const frontmatterErrors = await applyMarkdownFrontmatterPins(agentsDir, profile, markdownSubagentIds)
      await ctx.agent.reload()
      await ctx.session.switchModel({ sessionID, model: profile.primary })
      await ctx.session.synthetic({ sessionID, text: buildSummaryMessage(name, frontmatterErrors) })
    }

    // Snapshot at startup (not re-read per keystroke): command.transform's
    // callback must be synchronous, so the profile list/descriptions used for
    // the per-profile commands below are resolved once, here. A profile file
    // added after this plugin started won't get its own /profile-<name>
    // command until the next restart or hot-reload of this file — /profile
    // <name> (typed) still picks it up immediately since it reads disk fresh.
    const profileNames = await listProfiles(profilesDir).catch((error) => {
      warn(`cannot list profiles for command registration: ${toMessage(error)}`)
      return [] as string[]
    })
    const profileDescriptions = new Map<string, string>()
    for (const name of profileNames) {
      try {
        const profile = await loadProfile(profilesDir, name)
        profileDescriptions.set(name, `Switch to profile "${name}" (primary: ${formatRef(profile.primary)}).`)
      } catch (error) {
        profileDescriptions.set(name, `⚠ profile "${name}" is invalid: ${toMessage(error)}`)
      }
    }

    await ctx.command.transform((editor) => {
      editor.add({
        name: "profile",
        description:
          "Switch model profiles in-session. No args: list profiles. With a name: activate it (persisted across restarts).",
        async execute({ sessionID, prompt }) {
          const argument = prompt.text.trim().split(/\s+/)[0] ?? ""

          if (!argument) {
            await ctx.session.synthetic({ sessionID, text: await buildListMessage() })
            return
          }

          await applyProfileToSession(sessionID, argument)
        },
      })

      editor.add({
        name: "profile-failover-test",
        description:
          'Simulate a quota error for a model (default: current session model) and run the failover path; prefix with "dry" to rehearse without applying.',
        async execute({ sessionID, prompt }) {
          const text = await failover.runTest({ sessionID, argText: prompt.text })
          await ctx.session.synthetic({ sessionID, text })
        },
      })

      // One command per profile file, e.g. "profile-zai_and_free" — typing
      // "/profile" and pausing shows all of these (with descriptions) via
      // opencode's native by-name slash completion, giving a discoverable
      // list of profiles without remembering exact names.
      for (const name of profileNames) {
        editor.add({
          name: `profile-${name}`,
          description: profileDescriptions.get(name) ?? `Switch to profile "${name}".`,
          async execute({ sessionID }) {
            await applyProfileToSession(sessionID, name)
          },
        })
      }
    })

    // Failover cleanup (TTL timer, agent transforms, retry hook) is handed to
    // the SDK so a hot-reload of this plugin never leaves stale hooks behind.
    return failover.cleanup
  },
})
