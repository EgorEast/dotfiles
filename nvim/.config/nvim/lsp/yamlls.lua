return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      validate = true,
    },
  },
}
