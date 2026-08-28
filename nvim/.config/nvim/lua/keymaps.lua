-- Global key mappings. LSP-specific maps are buffer-local in lsp.lua;
-- file-manager and terminal maps live in their own modules.
local map = vim.keymap.set

-- Save (kept from the previous config)
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>ww", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>wa", "<cmd>wall<cr>", { desc = "Save all files" })

-- Marks (kept from the previous config)
map("n", "<leader>'", "", { desc = "Marks" })
local function del_marks()
  local marks = vim.fn.input("Delete marks: ")
  if marks ~= "" then
    vim.cmd("delmarks " .. marks)
  end
end
map("n", "<leader>'d", del_marks, { desc = "Delete marks" })
map("n", "dm", del_marks, { desc = "Delete marks" })

-- Clear search highlight
map({ "n", "i" }, "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>W", "", { desc = "Windows / resize" })
map("n", "<leader>W=", "<C-w>=", { desc = "Equalize windows" })
map("n", "<leader>Wh", "<cmd>vertical resize -4<cr>", { desc = "Narrower" })
map("n", "<leader>Wl", "<cmd>vertical resize +4<cr>", { desc = "Wider" })
map("n", "<leader>Wj", "<cmd>resize -2<cr>", { desc = "Shorter" })
map("n", "<leader>Wk", "<cmd>resize +2<cr>", { desc = "Taller" })

-- Tab pages (native tabs). <Tab>/<C-i> is left alone so the jumplist keeps working.
-- H / L move between tabs (overrides the default screen-top/bottom motions;
-- use zt / zb or gg / G for those). ]t / [t do the same.
map("n", "L", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "H", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "]t", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "[t", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader>t", "", { desc = "Tabs" })
map("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tT", "<cmd>tabnew %<cr>", { desc = "New tab (current file)" })
map("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader>t]", "<cmd>tabmove +1<cr>", { desc = "Move tab right" })
map("n", "<leader>t[", "<cmd>tabmove -1<cr>", { desc = "Move tab left" })
for i = 1, 9 do
  map("n", "<leader>t" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- Buffers. <leader>bd closes the tab (or the buffer if this is the only tab).
map("n", "<leader>b", "", { desc = "Buffers" })
map("n", "<leader>bd", function()
  if vim.fn.tabpagenr("$") > 1 then
    vim.cmd("tabclose")
  else
    vim.cmd("bdelete")
  end
end, { desc = "Close tab / buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Fuzzy find / grep are set up in lua/picker.lua (mini.pick).
-- Native fallbacks that don't need the picker:
map("n", "<leader>f/", ":find ", { desc = "Find file (native :find)" })
map("n", "<leader>s/", ":grep ", { desc = "Grep (native :grep -> quickfix)" })

-- Quickfix / location list
map("n", "<leader>x", "", { desc = "Lists / diagnostics" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "<leader>xq", function()
  local qf_open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 and win.loclist == 0 then
      qf_open = true
    end
  end
  vim.cmd(qf_open and "cclose" or "copen")
end, { desc = "Toggle quickfix list" })
map("n", "<leader>xl", function()
  local ok = pcall(vim.cmd, "lopen")
  if not ok then
    vim.cmd("lclose")
  end
end, { desc = "Toggle location list" })

-- Diagnostics (native vim.diagnostic; <C-w>d shows the float natively in 0.11+)
map("n", "<leader>xd", vim.diagnostic.setqflist, { desc = "Diagnostics -> quickfix" })
map("n", "<leader>xD", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Buffer diagnostics -> loclist" })

-- Search & replace (native :substitute with inccommand=split live preview)
map("n", "<leader>s", "", { desc = "Search / replace" })
map(
  "n",
  "<leader>sr",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word in file" }
)
map("x", "<leader>sr", [["zy:%s/<C-r>z//gI<Left><Left><Left>]], { desc = "Replace selection in file" })
-- Project-wide: grep for the word, then prefill :cdo so you just type the replacement.
map("n", "<leader>sR", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  vim.cmd("silent grep " .. vim.fn.shellescape([[\b]] .. word .. [[\b]]))
  if vim.fn.getqflist({ size = 0 }).size == 0 then
    vim.notify("No project matches for " .. word, vim.log.levels.WARN)
    return
  end
  vim.cmd("copen")
  local keys = [[:cdo s/\<]] .. word .. [[\>//gc | update]] .. string.rep("<Left>", 11)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end, { desc = "Replace word across project (grep + :cdo)" })

-- LSP refactor / actions (these degrade to a notice when no server is attached)
map("n", "<leader>r", "", { desc = "Rename" })
map("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename symbol (LSP)" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol (LSP)" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = { only = { "source" }, diagnostics = {} },
  })
end, { desc = "Source action (whole file)" })

-- Quick source actions (auto-apply when there is a single match).
local function source_action(kinds, desc)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = kinds, diagnostics = {} },
    })
  end
end
map("n", "<leader>cu", source_action(
  { "source.removeUnused", "source.removeUnusedImports", "source.removeUnused.ts" },
  "Remove unused code"
), { desc = "Remove unused code" })
map("n", "<leader>cM", source_action(
  { "source.addMissingImports", "source.addMissingImports.ts" },
  "Add missing imports"
), { desc = "Add missing imports" })
map("n", "<leader>co", source_action(
  { "source.organizeImports", "source.organizeImports.ts" },
  "Organize imports"
), { desc = "Organize imports" })

map("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer (LSP)" })

-- Move lines
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Native completion / snippet navigation in insert mode.
-- With vim.o.autocomplete the popup appears automatically; these make it feel like a plugin.
map("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Confirm completion / newline" })

map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  else
    return "<Tab>"
  end
end, { expr = true, desc = "Next completion / snippet jump" })

map({ "i", "s" }, "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<S-Tab>"
  end
end, { expr = true, desc = "Previous completion / snippet jump" })

map("i", "<C-Space>", function()
  vim.lsp.completion.get()
end, { desc = "Trigger LSP completion" })
