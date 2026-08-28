-- Plugin management via the built-in vim.pack (Neovim 0.12).
-- Kept to helpers with no native equivalent:
--   mason.nvim       LSP server / tool installer
--   mini.diff        git hunk signs in the sign column
--   mini.pick        fuzzy picker for files / live grep / buffers
--   nvim-treesitter  treesitter parser installer
--   which-key.nvim   popup showing available <leader> mappings as you type
--   tokyonight.nvim  colorscheme (cosmetic only)
--   grug-far.nvim    project-wide search & replace UI (ripgrep-backed)

-- Build/update hooks must be registered before vim.pack.add.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("cfg_pack_hooks", { clear = true }),
  callback = function(ev)
    local spec, kind = ev.data.spec, ev.data.kind
    if spec.name == "nvim-treesitter" and kind ~= "delete" then
      if not ev.data.active then
        pcall(vim.cmd.packadd, "nvim-treesitter")
      end
      -- Rebuild parsers against the new runtime.
      pcall(vim.cmd, "TSUpdate")
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/nvim-mini/mini.diff" },
  { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/MagicDuck/grug-far.nvim" },
})

-- Plugin manager commands / keymaps (LazyVim-style: <leader>l = "plugins") -----

vim.api.nvim_create_user_command("PackUpdate", function()
  -- Fetches remotes and opens a confirmation buffer listing every pending
  -- change per plugin. `:w` in that buffer applies, `:q` discards.
  vim.pack.update()
end, { desc = "Plugins: check + interactive update" })

vim.api.nvim_create_user_command("PackStatus", function()
  -- Offline: show current vs. lockfile state without hitting the network.
  vim.pack.update(nil, { offline = true })
end, { desc = "Plugins: status (offline)" })

vim.api.nvim_create_user_command("PackRestore", function()
  vim.pack.update(nil, { target = "lockfile", force = true })
  vim.notify("Plugins restored to nvim-pack-lock.json")
end, { desc = "Plugins: restore lockfile state" })

vim.api.nvim_create_user_command("PackList", function()
  local lines = { "# vim.pack plugins", "" }
  for _, p in ipairs(vim.pack.get()) do
    lines[#lines + 1] = ("%-18s %s  %s"):format(
      p.spec.name,
      p.active and "active" or "inactive",
      (p.spec.version or "")
    )
  end
  vim.notify(table.concat(lines, "\n"))
end, { desc = "Plugins: list installed" })

local map = vim.keymap.set
map("n", "<leader>l", "", { desc = "Plugins" })
map("n", "<leader>ll", "<cmd>PackUpdate<cr>", { desc = "Check / update plugins" })
map("n", "<leader>lu", "<cmd>PackUpdate<cr>", { desc = "Check / update plugins" })
map("n", "<leader>ls", "<cmd>PackStatus<cr>", { desc = "Plugin status (offline)" })
map("n", "<leader>lL", "<cmd>PackList<cr>", { desc = "List installed plugins" })
map("n", "<leader>lx", "<cmd>PackRestore<cr>", { desc = "Restore lockfile versions" })
map("n", "<leader>lc", "<cmd>checkhealth vim.pack<cr>", { desc = "Plugins healthcheck" })
map("n", "<leader>lp", "<cmd>TSUpdate<cr>", { desc = "Update treesitter parsers" })
