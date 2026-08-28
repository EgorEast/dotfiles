-- "What keys work here" reminders in special windows, shown in the winbar so
-- they don't get in the way. Covers the windows that aren't obvious.
local group = vim.api.nvim_create_augroup("cfg_hints", { clear = true })

local function winbar(text)
  vim.wo.winbar = "%#Comment# " .. text .. " "
end

-- vim.pack update / confirmation buffer (:PackUpdate)
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "nvim-pack",
  callback = function(ev)
    winbar("  :w  apply the listed updates     :q  cancel / close ")
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = ev.buf, desc = "Cancel updates" })
    vim.keymap.set("n", "g?", function()
      vim.notify(":w applies the updates shown below. :q closes without changing anything.")
    end, { buffer = ev.buf, desc = "Help" })
  end,
})

-- Quickfix / location list
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "qf",
  callback = function()
    winbar("  <CR>  jump to item     <C-w><CR>  open in split     q  close ")
  end,
})

-- Terminal floats opened by this config (yazi / lazygit): the TUI owns the keys,
-- just remind how to get out.
vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    local name = vim.b.term_title or vim.api.nvim_buf_get_name(0)
    if name:match("yazi") then
      winbar("  q  quit     ~ / <F1>  yazi help     <Enter>  open (in a new tab) ")
    elseif name:match("lazygit") then
      winbar("  q  quit     ?  lazygit help ")
    end
  end,
})

-- mini.pick footer is set in lua/picker.lua.
