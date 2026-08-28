-- Plugin management via the built-in vim.pack (Neovim 0.12).
-- Kept to helpers with no native equivalent:
--   mason.nvim       LSP server / tool installer
--   mini.diff        git hunk signs in the sign column
--   mini.pick        fuzzy picker for files / live grep / buffers
--   nvim-treesitter  treesitter parser installer
--   which-key.nvim   popup showing available <leader> mappings as you type
--   tokyonight.nvim  colorscheme (cosmetic only)

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
})

-- Convenience wrappers around the native API.
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update all vim.pack plugins" })

vim.api.nvim_create_user_command("PackStatus", function()
  vim.pack.update(nil, { offline = true })
end, { desc = "Show vim.pack plugin status" })
