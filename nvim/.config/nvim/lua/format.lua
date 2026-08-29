-- Format-on-save with external CLI formatters, falling back to the LSP.
--
-- Per filetype we shell out to a formatter (stdin -> stdout), same tools mason
-- installs. `prettier` only runs when the project actually configures it (a
-- .prettierrc*/prettier.config.* file, or a "prettier" key in package.json) -
-- with no config, a prettier-territory filetype is left alone rather than
-- handed to the language server. Filetypes with no CLI formatter at all fall
-- back to LSP formatting (dartls, lua_ls, ...).
--
-- Toggles:
--   <leader>uf   format-on-save for this buffer   (:FormatToggle)
--   <leader>uF   format-on-save globally          (:FormatToggle!)
--   <leader>cf   format the buffer now            (:Format)
-- Escape hatch: `vim.b.autoformat = false` in an ftplugin / autocmd.

local M = {}

-- CLI formatters -------------------------------------------------------------
-- `$FILENAME` is substituted with the buffer's path. Every command must read
-- the source on stdin and print the result on stdout.
local prettier = { name = "prettier", cmd = { "prettier", "--stdin-filepath", "$FILENAME" } }
local shfmt = { name = "shfmt", cmd = { "shfmt", "--filename", "$FILENAME", "-" } }

local by_ft = {
  lua = { { name = "stylua", cmd = { "stylua", "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" } } },
  sh = { shfmt },
  bash = { shfmt },
}
for _, ft in ipairs({
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "jsonc",
  "json5",
  "css",
  "scss",
  "less",
  "html",
  "vue",
  "svelte",
  "astro",
  "yaml",
  "markdown",
  "markdown.mdx",
  "graphql",
}) do
  by_ft[ft] = { prettier }
end

-- prettier config discovery -------------------------------------------------
local prettier_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
}

local prettier_cache = {}

local function has_prettier_config(fname)
  if fname == "" then
    return false
  end
  local dir = vim.fs.dirname(fname)
  if prettier_cache[dir] ~= nil then
    return prettier_cache[dir]
  end
  local found = vim.fs.find(prettier_files, { path = dir, upward = true, type = "file" })[1] ~= nil
  if not found then
    local pkg = vim.fs.find("package.json", { path = dir, upward = true, type = "file" })[1]
    if pkg then
      local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
      found = ok and type(data) == "table" and data.prettier ~= nil
    end
  end
  prettier_cache[dir] = found
  return found
end

-- runner ------------------------------------------------------------------
local function run_cli(buf, cmd)
  local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local res = vim.system(cmd, { stdin = input, text = true }):wait()
  if res.code ~= 0 then
    local err = ((res.stderr or "") .. (res.stdout or "")):gsub("%s+$", "")
    vim.notify(("format: %s exited %d\n%s"):format(cmd[1], res.code, err), vim.log.levels.WARN)
    return nil
  end
  local out = res.stdout or ""
  if out == "" then
    return nil
  end
  local lines = vim.split(out, "\n", { plain = true })
  if lines[#lines] == "" then
    lines[#lines] = nil
  end
  return lines
end

-- Replace only the changed middle so the cursor, folds and undo stay sane.
local function splice(buf, new)
  local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local s = 1
  while s <= #old and s <= #new and old[s] == new[s] do
    s = s + 1
  end
  local eo, en = #old, #new
  while eo >= s and en >= s and old[eo] == new[en] do
    eo, en = eo - 1, en - 1
  end
  if s > eo and s > en then
    return
  end
  vim.api.nvim_buf_set_lines(buf, s - 1, eo, false, vim.list_slice(new, s, en))
end

-- Format `buf` (or the current buffer). `opts.manual` reports when nothing ran.
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local fname = vim.api.nvim_buf_get_name(buf)
  local specs = by_ft[vim.bo[buf].filetype]

  for _, spec in ipairs(specs or {}) do
    local usable = vim.fn.executable(spec.cmd[1]) == 1 and (spec.name ~= "prettier" or has_prettier_config(fname))
    if usable then
      local out = run_cli(
        buf,
        vim.tbl_map(function(a)
          return a == "$FILENAME" and fname or a
        end, spec.cmd)
      )
      if out then
        splice(buf, out)
      end
      return
    end
  end

  -- A filetype we map to a CLI formatter is left untouched when that formatter
  -- isn't usable (e.g. prettier with no project config) - don't surprise-format
  -- it via the language server.
  if specs then
    if opts.manual then
      vim.notify("format: no configured formatter for '" .. vim.bo[buf].filetype .. "'", vim.log.levels.WARN)
    end
    return
  end

  -- Filetypes with no CLI formatter: let the LSP handle it if a client can.
  if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" }) > 0 then
    vim.lsp.buf.format({ bufnr = buf, async = false })
  elseif opts.manual then
    vim.notify("format: no formatter for '" .. vim.bo[buf].filetype .. "'", vim.log.levels.WARN)
  end
end

-- enable / disable --------------------------------------------------------
local function enabled(buf)
  local b = vim.b[buf].autoformat
  if b ~= nil then
    return b
  end
  return vim.g.autoformat ~= false
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("cfg_format_on_save", { clear = true }),
  callback = function(ev)
    if enabled(ev.buf) and vim.bo[ev.buf].filetype ~= "" then
      M.format({ buf = ev.buf })
    end
  end,
})

vim.api.nvim_create_user_command("Format", function()
  M.format({ manual = true })
end, { desc = "Format the current buffer" })

vim.api.nvim_create_user_command("FormatToggle", function(a)
  if a.bang then
    vim.b.autoformat = not enabled(0)
    vim.notify("Autoformat (buffer): " .. tostring(vim.b.autoformat))
  else
    vim.g.autoformat = not (vim.g.autoformat ~= false)
    vim.notify("Autoformat (global): " .. tostring(vim.g.autoformat))
  end
end, { bang = true, desc = "Toggle format-on-save (! = current buffer)" })

local map = vim.keymap.set
map("n", "<leader>cf", function()
  M.format({ manual = true })
end, { desc = "Format buffer" })
map("n", "<leader>uf", "<cmd>FormatToggle!<cr>", { desc = "Toggle format-on-save (buffer)" })
map("n", "<leader>uF", "<cmd>FormatToggle<cr>", { desc = "Toggle format-on-save (global)" })

return M
