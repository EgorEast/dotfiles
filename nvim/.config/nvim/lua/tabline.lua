-- Native tabline. Numbered tabs, modified marker, pin marker, a divider between
-- the pinned block and the rest, mouse-clickable regions. Ordering / pinning
-- logic lives in lua/tabs.lua.
local ic = require("icons")
local tabs = require("tabs")

local function label(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  local winnr = vim.fn.tabpagewinnr(tabnr)
  local bufnr = buflist[winnr]
  local name = vim.api.nvim_buf_get_name(bufnr)
  name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
  local modified = ""
  for _, b in ipairs(buflist) do
    if vim.bo[b].modified then
      modified = " " .. ic.modified
      break
    end
  end
  return name .. modified
end

function _G.Tabline()
  local current = vim.fn.tabpagenr()
  local handles = vim.api.nvim_list_tabpages()
  local last = vim.fn.tabpagenr("$")
  local parts = {}
  local prev_pinned = nil
  for i = 1, last do
    local pinned = handles[i] and tabs.is_pinned(handles[i]) or false
    if prev_pinned == true and pinned == false then
      parts[#parts + 1] = "%#TabLineFill#  " -- divider after the pinned block
    end
    prev_pinned = pinned

    local hl = (i == current) and "%#TabLineSel#" or "%#TabLine#"
    local pin = pinned and (ic.pin .. " ") or ""
    parts[#parts + 1] = table.concat({
      hl,
      "%", i, "T", -- clickable region
      " ", pin, i, ": ", label(i), " ",
    })
  end
  parts[#parts + 1] = "%#TabLineFill#%T"
  if last > 1 then
    parts[#parts + 1] = "%=%#TabLine#%999X  %X"
  end
  return table.concat(parts)
end

vim.o.tabline = "%!v:lua.Tabline()"
vim.o.showtabline = 2
