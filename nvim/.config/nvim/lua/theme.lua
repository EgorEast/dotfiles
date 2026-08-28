-- Colorscheme. tokyonight (as in LazyVim). Purely cosmetic — the only non-native
-- piece that touches nothing but highlight groups. Falls back to a built-in
-- scheme if the plugin has not been fetched yet.
local ok, tokyonight = pcall(require, "tokyonight")
if ok then
  tokyonight.setup({
    style = "night", -- "storm" | "moon" | "night" | "day"
    transparent = false,
    styles = {
      comments = { italic = true },
      keywords = { italic = false },
    },
  })
  vim.cmd.colorscheme("tokyonight")
else
  pcall(vim.cmd.colorscheme, "retrobox")
end
