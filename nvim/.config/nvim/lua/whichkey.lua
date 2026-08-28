-- which-key: popup that lists the mappings available under a prefix (e.g. <leader>)
-- while you type, plus a searchable list of everything. No native equivalent.
local ok, wk = pcall(require, "which-key")
if not ok then
  return
end

wk.setup({
  preset = "helix", -- compact box in the bottom-right corner
  delay = function(ctx)
    return ctx.plugin and 0 or 300
  end,
  icons = {
    mappings = false, -- don't require an icon provider
    keys = {}, -- plain key names
  },
  win = { border = "rounded" },
  spec = {
    { "<leader>b", group = "buffers" },
    { "<leader>c", group = "code / LSP" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>q", group = "session / quit" },
    { "<leader>r", group = "rename" },
    { "<leader>s", group = "search / replace" },
    { "<leader>t", group = "tabs" },
    { "<leader>u", group = "toggles" },
    { "<leader>x", group = "lists / diagnostics" },
    { "<leader>W", group = "windows" },
    { "<leader>l", group = "plugins" },
    { "<leader>'", group = "marks" },
  },
})

-- Show the full mapping list on demand.
vim.keymap.set("n", "<leader>?", function()
  wk.show({ global = true })
end, { desc = "Show all keymaps (which-key)" })
