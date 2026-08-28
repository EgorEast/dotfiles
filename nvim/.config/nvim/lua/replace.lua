-- Project-wide search & replace (grug-far.nvim, ripgrep-backed).
-- The old <leader>sr / <leader>sR native :substitute maps are replaced by this;
-- <leader>sn keeps a zero-UI single-file substitute for quick edits.
local ok, grug = pcall(require, "grug-far")
if not ok then
  return
end

grug.setup({
  headerMaxWidth = 80,
  keymaps = {
    replace = { n = "<localleader>r" },
    qflist = { n = "<localleader>q" },
    syncLocations = { n = "<localleader>s" },
    syncLine = { n = "<localleader>l" },
    close = { n = "q" },
    historyOpen = { n = "<localleader>t" },
    historyAdd = { n = "<localleader>a" },
    refresh = { n = "<localleader>f" },
    openLocation = { n = "<localleader>o" },
    gotoLocation = { n = "<enter>" },
    pickHistoryEntry = { n = "<enter>" },
    abort = { n = "<localleader>b" },
    help = { n = "g?" },
    toggleShowCommand = { n = "<localleader>p" },
  },
})

local map = vim.keymap.set

map("n", "<leader>sr", function()
  grug.open()
end, { desc = "Search & replace (project)" })

map("n", "<leader>sR", function()
  grug.open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search & replace (current file)" })

map("n", "<leader>sw", function()
  grug.open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search & replace word under cursor" })

map("x", "<leader>sr", function()
  grug.with_visual_selection()
end, { desc = "Search & replace selection" })

-- Quick, no-UI single-file substitute (native :s with inccommand preview).
map("n", "<leader>sn", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word in file" })
map("x", "<leader>sn", [["zy:%s/<C-r>z//gI<Left><Left><Left>]], { desc = "Substitute selection in file" })
