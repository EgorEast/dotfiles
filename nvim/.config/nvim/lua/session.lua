-- Native session management (:mksession). One session per working directory,
-- auto-saved on exit and auto-restored when you start `nvim` with no arguments.
-- Tab pages, window layout, folds and cursor positions are all preserved
-- (see 'sessionoptions' in options.lua).

local M = {}

local dir = vim.fn.stdpath("state") .. "/sessions/"
vim.fn.mkdir(dir, "p")

local function session_file(cwd)
  cwd = cwd or vim.fn.getcwd()
  local name = cwd:gsub("[\\/:]+", "%%")
  return dir .. name .. ".vim"
end

-- Autosave is armed only once a session is meaningfully in use.
M.autosave = false

function M.save()
  -- Don't persist special/scratch-only states.
  if vim.fn.argc() == 0 and vim.bo.buftype ~= "" and #vim.api.nvim_list_bufs() <= 1 then
    return
  end
  local ok = pcall(function()
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_file()))
  end)
  if not ok then
    return
  end
end

function M.load(cwd)
  local file = session_file(cwd)
  if vim.fn.filereadable(file) == 0 then
    vim.notify("No saved session for " .. (cwd or vim.fn.getcwd()), vim.log.levels.WARN)
    return false
  end
  -- Close the empty startup buffer cleanly first.
  vim.cmd("silent! %bwipeout")
  vim.cmd("silent! source " .. vim.fn.fnameescape(file))
  M.autosave = true
  return true
end

function M.delete()
  local file = session_file()
  if vim.fn.filereadable(file) == 1 then
    vim.fn.delete(file)
    vim.notify("Deleted session for " .. vim.fn.getcwd())
  end
  M.autosave = false
end

function M.stop()
  M.autosave = false
  vim.notify("Session autosave disabled for this run")
end

vim.api.nvim_create_user_command("SessionSave", function()
  M.autosave = true
  M.save()
  vim.notify("Session saved")
end, { desc = "Save session for cwd" })
vim.api.nvim_create_user_command("SessionLoad", function()
  M.load()
end, { desc = "Load session for cwd" })
vim.api.nvim_create_user_command("SessionDelete", M.delete, { desc = "Delete session for cwd" })
vim.api.nvim_create_user_command("SessionStop", M.stop, { desc = "Disable session autosave" })

vim.keymap.set("n", "<leader>q", "", { desc = "Session / quit" })
vim.keymap.set("n", "<leader>qs", function()
  M.load()
end, { desc = "Restore session (cwd)" })
vim.keymap.set("n", "<leader>qS", "<cmd>SessionSave<cr>", { desc = "Save session" })
vim.keymap.set("n", "<leader>qd", M.stop, { desc = "Stop session autosave" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

local group = vim.api.nvim_create_augroup("cfg_session", { clear = true })

-- Auto-restore on a bare `nvim` launch.
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  nested = true,
  callback = function()
    if vim.fn.argc() ~= 0 or vim.g.started_with_stdin then
      return
    end
    if vim.env.NVIM_NO_SESSION then
      return
    end
    if vim.fn.filereadable(session_file()) == 1 then
      vim.schedule(function()
        M.load()
      end)
    else
      M.autosave = true -- start a fresh session for this dir
    end
  end,
})

vim.api.nvim_create_autocmd("StdinReadPre", {
  group = group,
  callback = function()
    vim.g.started_with_stdin = true
  end,
})

-- Autosave on exit.
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if M.autosave then
      M.save()
    end
  end,
})

return M
