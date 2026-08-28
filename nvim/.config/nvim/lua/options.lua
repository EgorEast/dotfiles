-- Native editor options. Everything here is built in to Neovim 0.12.
local o = vim.o

-- UI
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.showmode = false
o.laststatus = 3 -- single global statusline
o.showtabline = 2 -- always show the native tabline
o.cmdheight = 1
o.pumheight = 12
o.pumblend = 0
o.winblend = 0
o.winborder = "rounded" -- native border for all floating windows (0.11+)
o.scrolloff = 6
o.sidescrolloff = 8
o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"
o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
vim.opt.fillchars = { eob = " ", fold = " ", foldsep = " ", diff = "╱" }

-- Native combined gutter: signs + number + fold column.
o.statuscolumn = "%s%=%{v:relnum ? v:relnum : v:lnum} %C"
o.foldcolumn = "0"

-- Editing
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.shiftround = true
o.smartindent = true
o.wrap = true -- requested
o.linebreak = true
o.breakindent = true
o.showbreak = "↪ "
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400
o.virtualedit = "block"
o.confirm = true
o.mouse = "a"
o.conceallevel = 2 -- lets native treesitter markdown hide markup

-- Search
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.inccommand = "split" -- live :substitute preview
-- hidden / ignored behaviour comes from RIPGREP_CONFIG_PATH, set in lua/picker.lua
o.grepprg = "rg --vimgrep"
o.grepformat = "%f:%l:%c:%m"

-- Native file finding via :find / gf
vim.opt.path:remove({ "/usr/include" })
vim.opt.path:append("**")
o.wildmenu = true
o.wildmode = "longest:full,full"
vim.opt.wildoptions = { "fuzzy", "pum", "tagfile" }
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/.dart_tool/*", "*/build/*", "*.o", "*.class" })

-- Native completion (0.12): built-in autocomplete popup + fuzzy matching.
o.autocomplete = true
o.completeopt = "menuone,noselect,popup,fuzzy"
o.pumborder = "rounded"
o.pummaxwidth = 50

-- Folding via native treesitter foldexpr (parser is attached per-buffer in treesitter.lua)
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
o.foldlevel = 99
o.foldlevelstart = 99

-- Spelling (user dictionaries live in spell/)
local config_path = vim.fn.stdpath("config")
o.spell = true
vim.opt.spelllang = { "en", "ru" }
o.spellfile = config_path .. "/spell/en.utf-8.add," .. config_path .. "/spell/ru.utf-8.add"
o.spellsuggest = "double"

-- Clipboard
o.clipboard = "unnamedplus"

-- Sessions
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize", "help" }

-- Colorscheme is set in lua/theme.lua (after plugins load).
