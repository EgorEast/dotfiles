-- Native LSP (Neovim 0.11+/0.12). No nvim-lspconfig, no mason-lspconfig.
-- Per-server settings live in the lsp/ directory and are picked up by name.

-- Diagnostics -----------------------------------------------------------------
-- Errors are shown where they happen: the offending range is underlined, a sign
-- marks the line, short text sits at the end of the line (virtual_text), and the
-- line under the cursor gets the full message expanded right below it
-- (virtual_lines). Nothing is dumped to the command line.
local icons = require("icons").diagnostics
local signs = {
  [vim.diagnostic.severity.ERROR] = icons.ERROR,
  [vim.diagnostic.severity.WARN] = icons.WARN,
  [vim.diagnostic.severity.INFO] = icons.INFO,
  [vim.diagnostic.severity.HINT] = icons.HINT,
}

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  float = { border = "rounded", source = "if_many", header = "", prefix = "" },
  virtual_text = {
    current_line = false, -- current line uses virtual_lines instead
    spacing = 2,
    prefix = "●",
    source = "if_many",
  },
  virtual_lines = { current_line = true },
  signs = { text = signs },
  jump = { float = true },
})

-- Toggle between the compact end-of-line text and the fully expanded lines.
vim.keymap.set("n", "<leader>ud", function()
  local cfg = vim.diagnostic.config()
  local expanded = cfg.virtual_lines == true or (type(cfg.virtual_lines) == "table" and not cfg.virtual_lines.current_line)
  if expanded then
    vim.diagnostic.config({
      virtual_text = { current_line = false, spacing = 2, prefix = "●", source = "if_many" },
      virtual_lines = { current_line = true },
    })
    vim.notify("Diagnostics: inline text")
  else
    vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
    vim.notify("Diagnostics: expanded lines")
  end
end, { desc = "Toggle diagnostic display style" })

-- Full message for the current line in a hover float.
vim.keymap.set("n", "<leader>cd", function()
  vim.diagnostic.open_float(nil, { scope = "line" })
end, { desc = "Line diagnostics (float)" })

-- Jump to an LSP location. A target in another file opens in a new tab (to match
-- the yazi behaviour); a target in the current file jumps in place. Multiple
-- results go to the quickfix list. `fn` is a vim.lsp.buf.* function.
local function goto_location(fn)
  fn({
    on_list = function(res)
      local items = res.items or {}
      if #items == 0 then
        return
      end
      if #items > 1 then
        vim.fn.setqflist({}, " ", res)
        vim.cmd("botright copen")
        return
      end
      local item = items[1]
      vim.cmd("normal! m'") -- keep a jumplist entry
      if vim.fn.fnamemodify(item.filename, ":p") ~= vim.fn.expand("%:p") then
        vim.cmd("tabedit " .. vim.fn.fnameescape(item.filename))
      end
      vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(0, (item.col or 1) - 1) })
      vim.cmd("normal! zz")
    end,
  })
end

-- Per-buffer setup on attach ------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf
    if not client then
      return
    end

    -- Native completion wired into the built-in popup (vim.o.autocomplete).
    -- Some servers (e.g. dartls) register completion dynamically after attach,
    -- so retry a couple of times before giving up.
    local function enable_completion(tries)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
      elseif (tries or 0) < 5 then
        vim.defer_fn(function()
          enable_completion((tries or 0) + 1)
        end, 500)
      end
    end
    enable_completion(0)

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
    end
    -- Defaults already provided by Neovim 0.11+: grn grr gra gri grt gO ]d [d K <C-w>d
    -- Rename / code action / format are global maps in keymaps.lua.
    map("n", "gd", function()
      goto_location(vim.lsp.buf.definition)
    end, "Go to definition (new tab)")
    map("n", "gD", function()
      goto_location(vim.lsp.buf.declaration)
    end, "Go to declaration (new tab)")
    map("n", "gy", function()
      goto_location(vim.lsp.buf.type_definition)
    end, "Go to type definition (new tab)")
    map("n", "<leader>cl", vim.lsp.codelens.run, "Run code lens")
    map("n", "<leader>ci", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
    end, "Toggle inlay hints")

    -- Highlight references of the symbol under the cursor.
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("cfg_lsp_highlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Enable servers. Each name maps to lsp/<name>.lua.
vim.lsp.enable({
  "lua_ls",
  "cssls",
  "css_variables",
  "emmet_language_server",
  "html",
  "jsonls",
  "eslint",
  "vtsls",
  "svelte",
  "astro",
  "dockerls",
  "yamlls",
  "taplo",
  "bashls",
  "marksman",
  "dartls",
})
