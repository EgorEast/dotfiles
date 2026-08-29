-- Neovim 0.12+ config built on native features only.
-- Plugins are limited to installers that have no native equivalent:
--   mason.nvim          -- LSP server / tool installer
--   mini.diff           -- git hunk signs in the sign column
--   nvim-treesitter     -- treesitter parser installer (highlighting itself is native)
-- See README.md for the rationale and the list of external binaries required.

if vim.fn.has("nvim-0.12") == 0 then
  vim.notify("This config requires Neovim 0.12+", vim.log.levels.ERROR)
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

for _, module in ipairs({
  "options",
  "keymaps",
  "autocmds",
  "pack",
  "theme",
  "servers",
  "treesitter",
  "lsp",
  "format",
  "git",
  "picker",
  "replace",
  "statusline",
  "tabs",
  "tabline",
  "filemanager",
  "term",
  "session",
  "whichkey",
  "hints",
}) do
  local ok, err = pcall(require, module)
  if not ok then
    vim.schedule(function()
      vim.notify(("Failed to load '%s':\n%s"):format(module, err), vim.log.levels.ERROR)
    end)
  end
end
