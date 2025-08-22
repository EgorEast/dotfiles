-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

--map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>w", ":w<CR>", { desc = "Save current tab" })
map("n", "<leader>ww", ":w<CR>", { desc = "Save current tab" })
map("n", "<leader>wa", ":wa<CR>", { desc = "Save all changed files" })

map("n", "<leader>'", "", { desc = "Marks" })

local del_marks = function()
  local marks = vim.fn.input("Delete marks: ")
  vim.cmd("delmarks " .. marks)
end
map("n", "<leader>'d", del_marks, {
  desc = "Delete marks",
})
map("n", "dm", del_marks, {
  desc = "Delete marks",
})
