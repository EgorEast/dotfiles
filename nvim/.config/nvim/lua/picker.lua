-- Fuzzy finding with mini.pick (same family as mini.diff, no dependencies).
--
-- Filters, all changeable live from inside the picker (see the footer hint):
--   <A-h>  include hidden files (dotfiles)          default below
--   <A-i>  include .gitignore'd / .ignore'd files   default below
--   <C-o>  add a glob filter, e.g.  *.lua   src/**   !**/test/**
--          (enter an empty pattern to clear all glob filters)
--   <C-e>  (grep only) toggle regex / plain matching
local search = {
  hidden = false,
  ignored = false,
  globs = {}, -- e.g. { "*.lua", "!**/node_modules/**" }
}

local ok, pick = pcall(require, "mini.pick")
if not ok then
  return
end

-- ripgrep reads this file on every run (grep + :grep), so toggling rewrites it.
local rg_conf = vim.fn.stdpath("state") .. "/rg-picker.conf"
local function write_rg_conf()
  local lines = { "--glob=!.git/", "--smart-case" }
  if search.hidden then
    lines[#lines + 1] = "--hidden"
  end
  if search.ignored then
    lines[#lines + 1] = "--no-ignore"
  end
  vim.fn.writefile(lines, rg_conf)
end
write_rg_conf()
vim.env.RIPGREP_CONFIG_PATH = rg_conf

local function suffix()
  local s = {}
  if search.hidden then
    s[#s + 1] = "hidden"
  end
  if search.ignored then
    s[#s + 1] = "no-ignore"
  end
  vim.list_extend(s, search.globs)
  return #s > 0 and (" [" .. table.concat(s, " ") .. "]") or ""
end

local function footer(kind)
  local glob = "  <C-o> glob filter"
  local method = kind == "grep" and "  <C-e> regex/plain" or ""
  return (" <CR> open  <C-v/s/t> splits%s%s  <A-h> hidden  <A-i> ignored  <Tab> preview  <S-Tab> keys "):format(
    glob,
    method
  )
end

local function win_config(kind)
  return function()
    local height = math.floor(0.65 * vim.o.lines)
    local width = math.floor(0.75 * vim.o.columns)
    return {
      anchor = "NW",
      height = height,
      width = width,
      row = math.floor(0.5 * (vim.o.lines - height)),
      col = math.floor(0.5 * (vim.o.columns - width)),
      border = "rounded",
      footer = footer(kind),
      footer_pos = "left",
    }
  end
end

pick.setup({
  mappings = { move_down = "<C-j>", move_up = "<C-k>" },
  window = { config = win_config() },
})

vim.ui.select = pick.ui_select

local b = pick.builtin
local map = vim.keymap.set

-- Shared live-filter actions: rewrite state, relaunch the same picker.
local function filter_maps(relaunch)
  local function toggle(field, char)
    return {
      char = char,
      func = function()
        search[field] = not search[field]
        write_rg_conf()
        vim.schedule(relaunch)
        return true
      end,
    }
  end
  return {
    toggle_hidden = toggle("hidden", "<A-h>"),
    toggle_ignored = toggle("ignored", "<A-i>"),
    add_glob = {
      char = "<C-o>",
      func = function()
        local g = vim.fn.input("Glob filter (empty = clear all): ")
        if g == "" then
          search.globs = {}
        else
          table.insert(search.globs, g)
        end
        vim.schedule(relaunch)
        return true
      end,
    },
  }
end

-- Files -----------------------------------------------------------------------
local function files_command()
  local cmd = { "fd", "--type", "f", "--color", "never", "--exclude", ".git" }
  if search.hidden then
    cmd[#cmd + 1] = "--hidden"
  end
  if search.ignored then
    cmd[#cmd + 1] = "--no-ignore"
  end
  for _, g in ipairs(search.globs) do
    vim.list_extend(cmd, { "--glob", g })
  end
  return cmd
end

local function pick_files()
  b.cli({ command = files_command() }, {
    source = { name = "Files" .. suffix() },
    mappings = filter_maps(pick_files),
    window = { config = win_config("files") },
  })
end

-- Live grep -----------------------------------------------------------------------
local function pick_grep()
  b.grep_live({ globs = vim.deepcopy(search.globs) }, {
    source = { name = "Grep" .. suffix() },
    mappings = filter_maps(pick_grep), -- <C-o> here re-prompts; native add-glob is <C-g>-less
    window = { config = win_config("grep") },
  })
end

local function pick_grep_word()
  b.grep(
    { pattern = vim.fn.expand("<cword>"), globs = vim.deepcopy(search.globs) },
    { source = { name = "Grep word" .. suffix() }, window = { config = win_config("grep") } }
  )
end

-- Keymaps -----------------------------------------------------------------------
map("n", "<leader>f", "", { desc = "Find" })
map("n", "<leader><space>", pick_files, { desc = "Find files" })
map("n", "<leader>ff", pick_files, { desc = "Find files" })
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

map("n", "<leader>sg", pick_grep, { desc = "Grep (live, all files)" })
map("n", "<leader>fg", pick_grep, { desc = "Grep (live, all files)" })
map("n", "<leader>/", pick_grep, { desc = "Grep (live, all files)" })
map("n", "<leader>fw", pick_grep_word, { desc = "Grep word under cursor" })

-- Commands for changing the filters outside a picker -------------------------
vim.api.nvim_create_user_command("SearchToggleHidden", function()
  search.hidden = not search.hidden
  write_rg_conf()
  vim.notify("Search hidden files: " .. tostring(search.hidden))
end, { desc = "Toggle searching hidden files" })

vim.api.nvim_create_user_command("SearchToggleIgnored", function()
  search.ignored = not search.ignored
  write_rg_conf()
  vim.notify("Search ignored files: " .. tostring(search.ignored))
end, { desc = "Toggle searching .gitignore'd files" })

vim.api.nvim_create_user_command("SearchGlob", function(o)
  if o.args == "" then
    search.globs = {}
    vim.notify("Search glob filters cleared")
  else
    search.globs = vim.split(o.args, "%s+", { trimempty = true })
    vim.notify("Search glob filters: " .. table.concat(search.globs, " "))
  end
end, { nargs = "*", desc = "Set glob filters for file/grep search (no args = clear)" })

vim.api.nvim_create_user_command("SearchFilters", function()
  vim.notify(("hidden=%s  ignored=%s  globs=[%s]"):format(
    tostring(search.hidden),
    tostring(search.ignored),
    table.concat(search.globs, " ")
  ))
end, { desc = "Show current search filters" })
