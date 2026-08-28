-- Syntax highlighting is native (vim.treesitter). The nvim-treesitter plugin is
-- used ONLY to fetch/compile parsers that don't ship with Neovim.
-- Bundled parsers on this system: bash c lua markdown markdown_inline query vim vimdoc.

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  return
end

local ensure = {
  "c",
  "comment",
  "css",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "printf",
  "regex",
  "scss",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "dart",
  "astro",
}

-- Install anything missing (async, no-op if already present). Building parsers
-- needs the `tree-sitter` CLI + a C compiler; on a fresh machine mason installs
-- tree-sitter-cli a moment after startup, so retry until it is available.
local function install_missing_parsers(attempt)
  attempt = attempt or 1
  local installed = ts.get_installed and ts.get_installed("parsers") or {}
  local lookup = {}
  for _, p in ipairs(installed) do
    lookup[p] = true
  end
  local todo = vim.tbl_filter(function(p)
    return not lookup[p]
  end, ensure)
  if #todo == 0 then
    return
  end
  if vim.fn.executable("tree-sitter") == 0 and vim.fn.executable("cc") == 0 then
    if attempt <= 20 then
      vim.defer_fn(function()
        install_missing_parsers(attempt + 1)
      end, 3000)
    end
    return
  end
  pcall(ts.install, todo)
end

vim.defer_fn(install_missing_parsers, 300)

-- Attach the native highlighter / indenter per buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("cfg_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    local ok_add, added = pcall(vim.treesitter.language.add, lang)
    if not (ok_add and added) then
      return
    end
    pcall(vim.treesitter.start, ev.buf, lang)
    if type(ts.indentexpr) == "function" then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Native incremental selection (an / in / ]n / [n) works out of the box in 0.12.
