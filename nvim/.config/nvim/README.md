# Neovim — native config (0.12+)

A deliberately small configuration built on **built-in Neovim features**. No
distribution, no framework. Plugins are limited to three installers that have no
native equivalent.

## What is native here

| Area | Mechanism |
|---|---|
| Syntax highlighting | `vim.treesitter` runtime, attached per buffer (`lua/treesitter.lua`) |
| LSP | `vim.lsp.enable` + `lsp/*.lua` (`lua/lsp.lua`) — no lspconfig |
| Completion | `vim.o.autocomplete` + `vim.lsp.completion` + `vim.snippet` |
| Diagnostics | `vim.diagnostic.config` — underline + sign + end-of-line text; current line's full message expanded below it (`virtual_lines`) |
| Sessions | native `:mksession` per cwd, auto-save/restore incl. tabs, layout, folds, cursor (`lua/session.lua`) |
| Keymap hints | `which-key.nvim` popup (bottom-right, `helix` preset) — no native equivalent |
| Git diff in gutter | `mini.diff` (only non-native piece for this) |
| Git UI | `:DiffTool`, `:Undotree` (native) + `:Lazygit` float |
| Tabs | native `tabline` (`lua/tabline.lua`) |
| Statusline + LSP progress | native `statusline` + `vim.lsp.status()` (`lua/statusline.lua`) |
| File manager | `yazi` in a native floating terminal (`lua/filemanager.lua`); netrw fallback |
| Fuzzy find | `mini.pick` — files / live grep / buffers / help (`lua/picker.lua`); hidden, ignored and glob filters changed live from the picker; `:find` / `:grep` kept as native fallback |
| Plugin manager | built-in `vim.pack` (`lua/pack.lua`) |
| Folding | `vim.treesitter.foldexpr` |
| Incremental selection | native (`an` / `in` / `]n` / `[n`) |

## Plugins (installers only)

- `mason.nvim` — installs language servers / formatters
- `mini.diff` — git hunk signs in the sign column
- `mini.pick` — fuzzy picker (files / live grep / buffers)
- `nvim-treesitter` (`main` branch) — fetches/compiles treesitter parsers
- `which-key.nvim` — popup listing available `<leader>` mappings as you type
- `tokyonight.nvim` — colorscheme (cosmetic only; `lua/theme.lua`)
- `grug-far.nvim` — project-wide search & replace UI (`lua/replace.lua`)

Managed by `vim.pack`; lockfile: `nvim-pack-lock.json` (committed).

Updating:

| Key / command | Action |
|---|---|
| `<leader>ll` / `:PackUpdate` | fetch remotes, show pending changes per plugin, `:w` to apply |
| `<leader>ls` / `:PackStatus` | offline status vs. lockfile |
| `<leader>lx` / `:PackRestore` | roll back to `nvim-pack-lock.json` |
| `<leader>lL` / `<leader>lc` | list plugins / `:checkhealth vim.pack` |
| `<leader>lp` / `:TSUpdate` | rebuild treesitter parsers |
| `<leader>cm` / `:Mason` | Mason UI (`C` check, `U` update, `X` uninstall) |
| `<leader>lm` / `:MasonEnsure` | install missing tools from the config's list |
| `<leader>lM` / `:MasonUpgrade` | update every installed Mason package |

After updating, commit `nvim-pack-lock.json` to pin the new versions.

In the update buffer: **`:w` applies** the listed changes, **`:q` cancels**
(also shown in its winbar). Same idea elsewhere — the quickfix list, the picker
and the yazi/lazygit floats each show their key hints in the winbar/footer; in
the picker `<S-Tab>` lists every mapping.

## Required external binaries

Core: `git`, `rg` (ripgrep), `fd`, `yazi`, `node`.
Optional: `lazygit`, `dart` (Dart LSP — from the Dart/Flutter SDK). A C compiler
(`cc`) is needed to build treesitter parsers; the `tree-sitter` CLI is installed
automatically through Mason.

Language servers, formatters, the tree-sitter CLI and treesitter parsers install
**automatically on first start** — just open `nvim` and wait for the notifications.
Dart's LSP comes from the SDK, not Mason; there is no Flutter run tooling.

## First run

Just start `nvim`. On the first launch it will, without any manual steps:

1. `vim.pack` clones the 3 helper plugins.
2. Mason installs the missing language servers / formatters (list in
   `lua/servers.lua`; re-run any time with `:MasonEnsure`).
3. `nvim-treesitter` compiles the missing parsers (retries until the CLI +
   compiler are ready).

Optional sanity check: `:checkhealth vim.lsp vim.pack vim.treesitter`.

## Key maps (leader = <Space>)

| Key | Action |
|---|---|
| `<leader>w` / `<leader>wa` | write / write all |
| `<leader>e` | file manager (yazi) — each picked file opens in a new tab |
| `<leader>cw` | yazi in cwd · `<C-Up>` resume |
| `<leader>E` | netrw fallback |
| `L` / `H` (or `]t` / `[t`) | next / prev tab |
| `<leader>tt` | new tab (`td` close, `to` only, `tn`/`tp` next/prev, `t1`-`t9`, `t[`/`t]` move) |
| `<leader>bd` | close tab (or buffer if only one tab) · `<leader>bD` force-delete buffer |
| `<leader>bp` / `<leader>bP` | pin/unpin tab (pinned collect at the front) · close all unpinned tabs |
| `<leader>b<` / `<leader>b>` (or `[B` / `]B`) | move tab left / right within its group |
| `<leader><space>` / `<leader>ff` | find files (mini.pick) |
| `<leader>fb` / `<leader>fh` / `<leader>fo` / `<leader>fr` | buffers / help / recent files / resume |
| `<leader>sg` / `<leader>/` | live grep across all files |
| `<leader>fw` | grep word under cursor |
| `<C-h>` / `<C-g>` (in picker) | toggle hidden / ignored files (also shown in the picker's winbar) |
| `<C-o>` / `<C-e>` (in picker) | add a glob filter (`*.lua`, `!**/test/**`; empty = clear) / grep regex↔plain |
| `:SearchGlob <globs>` / `:SearchToggleHidden` / `:SearchToggleIgnored` / `:SearchFilters` | change / show the filters outside a picker |
| `<leader>f/` / `<leader>s/` | native `:find` / `:grep` fallback |
| `<leader>sr` / `<leader>sw` | project search & replace (grug-far) / prefilled with word under cursor |
| `<leader>sR` (or visual `<leader>sr`) | grug-far scoped to current file / selection |
| `<leader>sn` | quick single-file `:%s` (no UI, live preview) |
| `<C-h/j/k/l>` or `<C-Left>`/`<C-Right>` | focus window · `<C-q>` close window |
| `<leader>Wc` / `<leader>Wo` / `<leader>Ws` / `<leader>Wv` | close / only / split / vsplit · `<leader>W{h,j,k,l}` resize |
| `<leader>xq` / `<leader>xl` | toggle quickfix / location list |
| `<leader>xd` | diagnostics → quickfix |
| `gd` `gD` `gy` | definition / declaration / type definition (other file → new tab) |
| `<C-o>` / `<C-i>` | jumplist back / forward — a jump to another file focuses that file's tab; the opposite key jumps back across tabs |
| `<leader>?` | searchable list of all keymaps (which-key) |
| `grr` `gri` `grt` `gO` | native LSP: refs / impl / type def / document symbols |
| `<leader>rr` / `<leader>cr` | rename symbol |
| `<leader>ca` / `<leader>cA` | code action / source action (whole file) |
| `<leader>cu` / `<leader>cM` / `<leader>co` | remove unused / add missing imports / organize imports |
| `<leader>cf` / `<leader>ci` / `<leader>cl` | format / toggle inlay hints / run code lens |
| `<leader>cd` / `<leader>ud` | line diagnostics float / toggle inline ⇄ expanded style |
| `]d` / `[d`, `<C-w>d` | diagnostic nav / float (native) |
| `]h` / `[h`, `gh` / `gH` | git hunk nav / apply / reset (mini.diff) |
| `<leader>gd` `<leader>gD` `<leader>gu` | diff overlay / `:DiffTool` / undo tree |
| `<leader>gg` | lazygit float |
| `<leader>ll` / `<leader>cm` | update plugins / open Mason (see Updating above) |
| `<leader>qs` / `<leader>qS` / `<leader>qd` | restore / save / stop-autosave session |
| `<leader>'d` / `dm` | delete marks |

## Layout

```
init.lua            module loader
lua/options.lua     editor options
lua/keymaps.lua     global maps
lua/autocmds.lua    autocommands
lua/pack.lua        vim.pack + build hooks
lua/servers.lua     mason installer + PATH + :MasonEnsure
lua/treesitter.lua  parser install + native highlight attach
lua/lsp.lua         diagnostics, LspAttach, vim.lsp.enable
lua/git.lua         mini.diff + branch cache
lua/picker.lua      mini.pick config + find/grep maps
lua/replace.lua     grug-far project search & replace
lua/statusline.lua  native statusline
lua/tabs.lua        tab pinning / ordering / reorder
lua/tabline.lua     native tabline
lua/filemanager.lua yazi float wrapper + netrw settings
lua/term.lua        floating-terminal helper (lazygit)
lua/session.lua     per-cwd session auto-save / restore
lua/whichkey.lua    which-key popup config
lua/hints.lua       winbar key hints for special windows
lua/theme.lua       colorscheme (tokyonight)
lsp/*.lua           per-server config
ftdetect/ ftplugin/ syntax/   kitty.conf support (replaces vim-kitty)
spell/              en/ru user dictionaries
```

The previous LazyVim setup is preserved under `dotfiles/nvim.lazyvim/`.
