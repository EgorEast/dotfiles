-- Fuzzy finding with mini.pick (same family as mini.diff, no dependencies).
--
-- Hidden files and .gitignore'd files: off by default, toggled live inside the
-- picker with <A-h> (hidden) and <A-i> (ignored). Change the defaults here:
local search = {
  hidden = false, -- include dotfiles / dot-directories
  ignored = false, -- include files excluded by .gitignore / .ignore
}

local ok, pick = pcall(require, "mini.pick")
if not ok then
  return
end

-- ripgrep reads this config file on every run (grep_live + :grep), so toggling
-- rewrites it. fd takes the same flags directly (see files_command).
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
  return #s > 0 and (" [" .. table.concat(s, "+") .. "]") or ""
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
        footer = " <CR> open  <C-v/s/t> splits  <A-h> hidden  <A-i> ignored  <Tab> preview  <S-Tab> keys  <Esc> close ",
        footer_pos = "left",
      }
    end,
  },
})

vim.ui.select = pick.ui_select

local b = pick.builtin
local map = vim.keymap.set

-- Toggle mappings shared by the file and grep pickers. They rewrite the rg
-- config, then relaunch the same picker.
local function toggles(relaunch)
  local function toggle(key)
    return {
      char = key == "hidden" and "<A-h>" or "<A-i>",
      func = function()
        search[key] = not search[key]
        write_rg_conf()
        vim.schedule(relaunch)
        return true -- close current picker
      end,
    }
  end
  return { toggle_hidden = toggle("hidden"), toggle_ignored = toggle("ignored") }
end

-- Files ---------------------------------------------------------------------
local function files_command()
  local cmd = { "fd", "--type", "f", "--color", "never", "--exclude", ".git" }
  if search.hidden then
    cmd[#cmd + 1] = "--hidden"
  end
  if search.ignored then
    cmd[#cmd + 1] = "--no-ignore"
  end
  return cmd
end

local function pick_files()
  b.cli({ command = files_command() }, {
    source = { name = "Files" .. suffix() },
    mappings = toggles(pick_files),
  })
end

-- Live grep ---------------------------------------------------------------------
local function pick_grep()
  b.grep_live({}, {
    source = { name = "Grep" .. suffix() },
    mappings = toggles(pick_grep),
  })
end

local function pick_grep_word()
  b.grep({ pattern = vim.fn.expand("<cword>") }, { source = { name = "Grep word" .. suffix() } })
end

-- Keymaps ---------------------------------------------------------------------
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
