/**
 * profile — global in-session model-profile switcher.
 *
 * Global fallback for projects without their own `.opencode/plugins/profile`
 * (e.g. exarh-web). slovo-propovedi-mobile keeps its own project-local copy
 * of this plugin as the source of truth there — see that project's
 * `.opencode/plugins/profile/index.ts` for the full design rationale
 * (mode-based agent registry pinning, no TUI dialog, etc). This file mirrors
 * it, with two differences:
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
 */

import * as fs from "node:fs/promises"
import * as path from "node:path"
import { Model, Plugin } from "@opencode/plugin"

/** This file's own directory — .../plugins/profile — independent of the current project. */
const PLUGIN_DIR = import.meta.dir

/** Plugin-scoped storage key holding the active profile name. */
const STORAGE_KEY = "activeProfile"

/** The 7 agent slots wired from a profile file, in display order. */
const PROFILE_AGENTS = ["plan", "build", "researcher", "coder", "explore", "scribe", "reviewer"] as const

/** A parsed "provider/model[#variant]" reference — the canonical Model.Ref, trusted after the boundary. */
type ModelRef = Model.Ref

interface ProfileData {
  primary: ModelRef
  agents: Record<string, ModelRef>
}

function toMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error)
}

/** Render a ModelRef back to its "provider/model[#variant]" string form. */
function formatRef(ref: ModelRef): string {
  return ref.variant ? `${ref.providerID}/${ref.id}#${ref.variant}` : `${ref.providerID}/${ref.id}`
}

/** Human-readable rendering of an arbitrary value for error messages. */
function formatValue(value: unknown): string {
  if (typeof value === "string") return `"${value}"`
  if (value === null) return "null"
  if (typeof value === "object") return JSON.stringify(value) ?? String(value)
  return String(value)
}

/**
 * Parse "provider/model#variant" into the canonical Model.Ref (Law 4: Fail Fast).
 * Throws for malformed values; callers add profile/field context.
 */
function parseModelRef(raw: string): ModelRef {
  return Model.Ref.parse(raw)
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

/** True when the error means "file does not exist on disk". */
function isMissingFileError(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && error.code === "ENOENT"
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
    const storedProfile = await ctx.storage.get(STORAGE_KEY)
    const warn = (message: string): void => {
      console.warn(`[profile] ${message}`)
    }

    // Reserved for the /profile command; the agent registry transform reads it.
    let activeProfile: ProfileData | null = null
    let activeProfileName: string | null = null

    if (typeof storedProfile === "string" && storedProfile) {
      try {
        activeProfile = await loadProfile(profilesDir, storedProfile)
        activeProfileName = storedProfile
      } catch (error) {
        warn(`stored profile "${storedProfile}" could not be loaded: ${toMessage(error)} — starting with defaults`)
        if (isMissingFileError(error)) {
          await ctx.storage.remove(STORAGE_KEY)
        }
      }
    }

    await ctx.agent.transform((editor) => {
      if (!activeProfile) return

      for (const [agentId, modelRef] of Object.entries(activeProfile.agents)) {
        const agent = editor.get(agentId)
        if (!agent) {
          warn(`profile "${activeProfileName}" references unknown agent "${agentId}" — skipped`)
          continue
        }
        // An agent with its own registry-configured model always wins over the
        // session's live model. Pinning a "primary" agent here would
        // permanently defeat ctx.session.switchModel below for it — plan/build
        // must stay unpinned so switchModel remains the sole, immediate
        // switch mechanism for the current session. Only true subagents get
        // pinned: their model is resolved once, at spawn time, from the
        // registry, with no session of their own for switchModel to target.
        if (agent.mode !== "subagent") continue
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

    const buildSummaryMessage = (name: string): string => {
      const profile = activeProfile
      if (!profile) {
        return `✅ Profile "${name}" activated. Primary and subagent models are set.`
      }
      const subagentSummary = PROFILE_AGENTS.map((agentId) => {
        const modelRef = profile.agents[agentId]
        return `    ${agentId}: ${modelRef ? formatRef(modelRef) : "(unset — skipped)"}`
      }).join("\n")
      return [
        `✅ Profile switched to "${name}".`,
        `  primary: ${formatRef(profile.primary)} (applied to this session now)`,
        "  subagents (apply at next spawn):",
        subagentSummary,
      ].join("\n")
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
      await ctx.storage.set(STORAGE_KEY, name)
      await ctx.agent.reload()
      await ctx.session.switchModel({ sessionID, model: profile.primary })
      await ctx.session.synthetic({ sessionID, text: buildSummaryMessage(name) })
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
  },
})
