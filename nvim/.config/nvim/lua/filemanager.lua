-- File manager: a thin native wrapper around the `yazi` binary using a floating
-- terminal window and yazi's --chooser-file. No plugin involved.
-- netrw (tree style) stays available as a fallback.

local M = { last_dir = nil }

local function float_win(bufopts)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = bufopts and bufopts.title or nil,
    title_pos = "center",
  })
  return buf, win
end

function M.open(path)
  if vim.fn.executable("yazi") == 0 then
    vim.notify("yazi is not installed", vim.log.levels.ERROR)
    return
  end
  path = path or vim.fn.expand("%:p:h")
  if path == "" or vim.fn.isdirectory(path) == 0 then
    path = vim.fn.getcwd()
  end
  M.last_dir = path

  local chooser = vim.fn.tempname()
  local _, win = float_win({ title = " yazi " })

  vim.fn.jobstart({ "yazi", path, "--chooser-file", chooser }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      local ok, lines = pcall(vim.fn.readfile, chooser)
      pcall(vim.fn.delete, chooser)
      if ok and lines and #lines > 0 then
        for _, file in ipairs(lines) do
          if file ~= "" then
            local path = vim.fn.fnameescape(file)
            -- Open each picked file in its own tab. Reuse the current tab only if
            -- it is a single empty throwaway buffer (e.g. right after `nvim`).
            local buf = vim.api.nvim_get_current_buf()
            local empty_tab = #vim.api.nvim_tabpage_list_wins(0) == 1
              and vim.api.nvim_buf_get_name(buf) == ""
              and not vim.bo[buf].modified
              and vim.api.nvim_buf_line_count(buf) == 1
              and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
            vim.cmd((empty_tab and "edit " or "tabedit ") .. path)
          end
        end
      end
    end,
  })
  vim.cmd("startinsert")
end

function M.resume()
  M.open(M.last_dir)
end

vim.api.nvim_create_user_command("Yazi", function(opts)
  local arg = opts.args
  if arg == "" then
    M.open()
  elseif arg == "cwd" then
    M.open(vim.fn.getcwd())
  elseif arg == "resume" then
    M.resume()
  else
    M.open(vim.fn.expand(arg))
  end
end, { nargs = "?", complete = "dir", desc = "Open yazi (arg: dir | cwd | resume)" })

-- Keymaps (kept from the previous config)
vim.keymap.set("n", "<leader>e", M.open, { desc = "File manager (yazi)" })
vim.keymap.set("n", "<leader>cw", function()
  M.open(vim.fn.getcwd())
end, { desc = "File manager in cwd" })
vim.keymap.set("n", "<C-Up>", M.resume, { desc = "Resume yazi" })
vim.keymap.set("n", "<leader>E", "<cmd>Explore<cr>", { desc = "netrw (fallback explorer)" })

-- netrw configuration for the fallback path
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = "cp -r"

-- Open yazi when Neovim is started on a directory.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("cfg_yazi_hijack", { clear = true }),
  callback = function()
    local arg = vim.fn.argv(0)
    if type(arg) == "string" and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      local dir = vim.fn.fnamemodify(arg, ":p")
      -- wipe the empty directory buffer netrw would create
      vim.schedule(function()
        pcall(vim.cmd, "bwipeout!")
        M.open(dir)
      end)
    end
  end,
})

return M
