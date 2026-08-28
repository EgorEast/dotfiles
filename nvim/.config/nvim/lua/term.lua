-- Floating-terminal helper for external TUIs (lazygit).
-- Pure native: nvim_open_win + jobstart({ term = true }).

local M = {}

local function float_term(cmd, opts)
  opts = opts or {}
  local width = math.floor(vim.o.columns * (opts.scale or 0.9))
  local height = math.floor(vim.o.lines * (opts.scale or 0.9))
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = opts.title and (" " .. opts.title .. " ") or nil,
    title_pos = "center",
  })

  local job = vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function(_, code)
      if opts.on_exit then
        opts.on_exit(code)
      end
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
  return job, buf, win
end

_G.FloatTerm = float_term

local function tool_command(name, bin, opts)
  vim.api.nvim_create_user_command(name, function()
    if vim.fn.executable(bin) == 0 then
      vim.notify(bin .. " is not installed", vim.log.levels.ERROR)
      return
    end
    float_term({ bin }, vim.tbl_extend("force", { title = bin }, opts or {}))
  end, { desc = "Open " .. bin .. " in a floating terminal" })
end

tool_command("Lazygit", "lazygit")

vim.keymap.set("n", "<leader>gg", "<cmd>Lazygit<cr>", { desc = "Git: lazygit" })

return M
