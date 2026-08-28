-- Native autocommands. All handlers use built-in APIs only.
local function augroup(name)
  return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end
local au = vim.api.nvim_create_autocmd

-- Briefly highlight yanked text
au("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Restore last cursor position when reopening a file
au("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" or vim.bo[ev.buf].filetype == "gitrebase" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create missing parent directories on save
au("BufWritePre", {
  group = augroup("mkdir_on_save"),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local dir = vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Terminal buffers: no line numbers, enter insert mode
au("TermOpen", {
  group = augroup("terminal"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.spell = false
    vim.cmd("startinsert")
  end,
})

-- Equalize splits when the UI is resized
au("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.api.nvim_get_current_tabpage()
    vim.cmd("tabdo wincmd =")
    pcall(vim.api.nvim_set_current_tabpage, tab)
  end,
})

-- Close throwaway buffers with q
au("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "query", "git" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Keep the statusline's LSP progress text live (vim.lsp.status()).
au("LspProgress", {
  group = augroup("lsp_progress_redraw"),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- Wrap + spell for prose
au("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
