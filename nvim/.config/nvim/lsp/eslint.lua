-- Only attach when the project actually has an ESLint config, otherwise the
-- server spams textDocument/diagnostic failures.
local configs = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

return {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "astro",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.find(configs, { path = vim.fs.dirname(fname), upward = true })[1]
    if found then
      on_dir(vim.fs.dirname(found))
    end
  end,
  settings = {
    validate = "on",
    workingDirectory = { mode = "auto" },
    experimental = { useFlatConfig = false },
    codeActionOnSave = { enable = false, mode = "all" },
  },
}
