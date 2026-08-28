-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local config_path = vim.fn.stdpath("config")

opt.spelllang = { "en", "ru" }
opt.spellfile = config_path .. "/spell/en.utf-8.add" .. "," .. config_path .. "/spell/ru.utf-8.add"
opt.spell = true
opt.spellsuggest = "double"
opt.wrap = true

opt.clipboard = "unnamedplus"
