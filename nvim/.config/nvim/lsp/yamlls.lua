return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      validate = true,
      customTags = { "!vault" },
      -- yaml-language-server matches schemaStore fileMatch globs against the
      -- *absolute* path, and its glob engine lets a bare `*` cross `/`. Any
      -- repo living under a directory literally named "playbooks" (as ours
      -- do, under ~/playbooks/) gets every *.yml file misidentified as an
      -- "Ansible Playbook" (schema wants an array) by `**/playbooks/*.yml`.
      -- Pinning the schemas we actually want at Settings priority (which
      -- outranks SchemaStore priority) overrides that false match.
      schemas = {
        ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/vars.json"] = {
          "**/host_vars/*.yml",
          "**/host_vars/*.yaml",
          "**/group_vars/*.yml",
          "**/group_vars/*.yaml",
          "**/vars/*.yml",
          "**/vars/*.yaml",
        },
        ["https://json.schemastore.org/github-workflow.json"] = {
          ".github/workflows/*.yml",
          ".github/workflows/*.yaml",
          ".forgejo/workflows/*.yml",
          ".forgejo/workflows/*.yaml",
          ".gitea/workflows/*.yml",
          ".gitea/workflows/*.yaml",
        },
      },
    },
  },
}
