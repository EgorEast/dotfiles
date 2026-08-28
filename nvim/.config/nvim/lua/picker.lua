-- Fuzzy finding with mini.pick (same family as mini.diff, no dependencies).
-- Files come from git / rg / fd automatically; grep is live ripgrep.
local ok, pick = pcall(require, "mini.pick")
if not ok then
  return
end

pick.setup({
  mappings = {
    move_down = "<C-j>",
    move_up = "<C-k>",
  },
  window = {
    config = function()
      local height = math.floor(0.65 * vim.o.lines)
      local width = math.floor(0.75 * vim.o.columns)
      return {
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        border = "rounded",
        footer = " <CR> open  <C-v/s/t> vsplit/split/tab  <C-x> mark  <Tab> preview  <S-Tab> all keys  <Esc> close ",
        footer_pos = "left",
      }
    end,
  },
})

-- Route vim.ui.select (code actions, etc.) through the picker.
vim.ui.select = pick.ui_select

local b = pick.builtin
local map = vim.keymap.set

map("n", "<leader>f", "", { desc = "Find" })
map("n", "<leader><space>", function()
  b.files()
end, { desc = "Find files" })
map("n", "<leader>ff", function()
  b.files()
end, { desc = "Find files" })
map("n", "<leader>fb", function()
  b.buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fh", function()
  b.help()
end, { desc = "Find help tags" })
map("n", "<leader>fr", function()
  b.resume()
end, { desc = "Resume last picker" })
map("n", "<leader>fo", function()
  local items = vim.tbl_filter(function(p)
    return vim.fn.filereadable(p) == 1
  end, vim.v.oldfiles)
  pick.start({ source = { items = items, name = "Recent files", choose = pick.default_choose } })
end, { desc = "Recent files" })

-- Content search across all files (live ripgrep).
map("n", "<leader>sg", function()
  b.grep_live()
end, { desc = "Grep (live, all files)" })
map("n", "<leader>/", function()
  b.grep_live()
end, { desc = "Grep (live, all files)" })
map("n", "<leader>sw", function()
  b.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })
map("n", "<leader>fg", function()
  b.grep_live()
end, { desc = "Grep (live, all files)" })
