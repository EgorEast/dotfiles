-- Native statusline. Set via 'statusline' = %!v:lua... and rebuilt on redraw.
-- LSP indexing progress is surfaced through the built-in vim.lsp.status().

local MODES = {
  n = "NORMAL",
  no = "O-PENDING",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
  i = "INSERT",
  ic = "INSERT",
  R = "REPLACE",
  Rv = "V-REPLACE",
  c = "COMMAND",
  cv = "EX",
  r = "PROMPT",
  rm = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  t = "TERMINAL",
}

local ic = require("icons")

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local parts = {}
  local map = {
    { vim.diagnostic.severity.ERROR, "%#DiagnosticError#" .. ic.diagnostics.ERROR .. " " },
    { vim.diagnostic.severity.WARN, "%#DiagnosticWarn#" .. ic.diagnostics.WARN .. " " },
    { vim.diagnostic.severity.INFO, "%#DiagnosticInfo#" .. ic.diagnostics.INFO .. " " },
    { vim.diagnostic.severity.HINT, "%#DiagnosticHint#" .. ic.diagnostics.HINT .. " " },
  }
  for _, item in ipairs(map) do
    local n = counts[item[1]]
    if n and n > 0 then
      parts[#parts + 1] = item[2] .. n
    end
  end
  return #parts > 0 and (table.concat(parts, " ") .. "%*") or ""
end

local function git()
  local branch = vim.b.git_branch
  if not branch then
    return ""
  end
  local out = "%#Constant#" .. ic.branch .. " " .. branch .. "%*"
  local ok, data = pcall(function()
    return require("mini.diff").get_buf_data(0)
  end)
  if ok and data and data.summary then
    local s = data.summary
    local seg = {}
    if (s.add or 0) > 0 then
      seg[#seg + 1] = "%#DiagnosticOk#+" .. s.add
    end
    if (s.change or 0) > 0 then
      seg[#seg + 1] = "%#DiagnosticWarn#~" .. s.change
    end
    if (s.delete or 0) > 0 then
      seg[#seg + 1] = "%#DiagnosticError#-" .. s.delete
    end
    if #seg > 0 then
      out = out .. " " .. table.concat(seg, " ") .. "%*"
    end
  end
  return out
end

local function lsp_progress()
  local msg = vim.lsp.status()
  if not msg or msg == "" then
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      names[#names + 1] = client.name
    end
    return #names > 0 and ("%#Comment#" .. ic.lsp .. " " .. table.concat(names, ",") .. "%*") or ""
  end
  if #msg > 50 then
    msg = msg:sub(1, 49) .. "…"
  end
  return "%#Comment#" .. ic.lsp .. " " .. msg .. "%*"
end

function _G.Statusline()
  local mode = MODES[vim.api.nvim_get_mode().mode] or vim.api.nvim_get_mode().mode
  return table.concat({
    "%#StatusLine# ",
    mode,
    " %#StatusLineNC#",
    " %f %m%r%h%w",
    " ",
    git(),
    "%=",
    lsp_progress(),
    "  ",
    diagnostics(),
    "  %#StatusLineNC#%y ",
    "%#StatusLine# %l:%c %P ",
  })
end

vim.o.statusline = "%!v:lua.Statusline()"

-- Cheap redraw so the mode segment updates promptly.
vim.api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged", "BufEnter", "LspAttach", "LspDetach" }, {
  group = vim.api.nvim_create_augroup("cfg_statusline", { clear = true }),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
