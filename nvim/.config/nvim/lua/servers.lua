-- mason.nvim is used ONLY as an installer for language servers, formatters and
-- linters. No mason-lspconfig, no automatic bridging: lsp/*.lua files call the
-- binaries by name and mason prepends its bin dir (~/.local/share/nvim/mason/bin)
-- to $PATH when it loads, which is why this module is required before lsp.lua.
local ok, mason = pcall(require, "mason")
if not ok then
  return
end

-- Make sure mason's bin dir is on PATH for this process (and therefore for every
-- LSP server we spawn and for nvim-treesitter's `tree-sitter` CLI). mason.setup()
-- is supposed to do this, but doing it explicitly removes any ordering doubt.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not (vim.env.PATH or ""):find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
end

mason.setup({
  ui = {
    border = "rounded",
    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

-- Tools this config expects. Dart's LSP ships with the Flutter/Dart SDK, so it is
-- intentionally absent here. tree-sitter-cli is needed to build parsers.
local ensure = {
  "tree-sitter-cli",
  "lua-language-server",
  "css-lsp",
  "css-variables-language-server",
  "emmet-language-server",
  "html-lsp",
  "json-lsp",
  "eslint-lsp",
  "vtsls",
  "svelte-language-server",
  "astro-language-server",
  "dockerfile-language-server",
  "yaml-language-server",
  "taplo",
  "bash-language-server",
  "marksman",
  "shfmt",
  "shellcheck",
  "stylua",
  "prettier",
}

-- Install whatever is missing. Runs both on demand (:MasonEnsure) and
-- automatically on startup, so a fresh machine needs no manual steps.
local function ensure_installed(notify_when_noop)
  local registry = require("mason-registry")
  local function run()
    local missing = {}
    for _, name in ipairs(ensure) do
      local pkg_ok, pkg = pcall(registry.get_package, name)
      if pkg_ok and not pkg:is_installed() then
        missing[#missing + 1] = pkg
      end
    end
    if #missing == 0 then
      if notify_when_noop then
        vim.notify("mason: all tools already installed", vim.log.levels.INFO)
      end
      return
    end
    vim.notify(
      ("mason: installing %d tool(s): %s"):format(
        #missing,
        table.concat(
          vim.tbl_map(function(p)
            return p.name
          end, missing),
          ", "
        )
      ),
      vim.log.levels.INFO
    )
    for _, pkg in ipairs(missing) do
      pkg:install()
    end
  end
  if registry.refresh then
    registry.refresh(run)
  else
    run()
  end
end

vim.api.nvim_create_user_command("MasonEnsure", function()
  ensure_installed(true)
end, { desc = "Install any missing language servers / tools" })

-- First-run automation: bootstrap any missing tools shortly after startup.
vim.defer_fn(function()
  pcall(ensure_installed, false)
end, 1500)
