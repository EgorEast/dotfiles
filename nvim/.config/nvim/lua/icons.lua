-- Nerd Font glyphs built from codepoints so they never depend on this file's
-- byte encoding surviving copy/paste or tooling. Font Awesome range (U+F0xx)
-- is present in every Nerd Font, JetBrains Mono NF included.
local c = vim.fn.nr2char

return {
  diagnostics = {
    ERROR = c(0xf057), -- times-circle
    WARN = c(0xf071), -- exclamation-triangle
    INFO = c(0xf05a), -- info-circle
    HINT = c(0xf0eb), -- lightbulb-o
  },
  git = {
    added = c(0x258e), -- ▎
    changed = c(0x258e), -- ▎
    removed = c(0x2581), -- ▁
  },
  pin = c(0xf08d), -- thumbtack
  modified = c(0x25cf), -- ●
  branch = c(0xe0a0), -- powerline branch
  lsp = c(0xf085), -- gears
}
