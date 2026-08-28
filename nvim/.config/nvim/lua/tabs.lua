-- Tab ordering: pinned tabs are kept at the front (in the order they were
-- pinned); unpinned tabs keep their creation order, so unpinning a tab returns
-- it to its original spot. Tabs can be reordered within their own group.
--
-- State is held in tab-local vars:
--   t:pinned   boolean flag (also read by the tabline)
--   t:pin_seq  order among pinned tabs
--   t:ordinal  stable creation order among all tabs
local M = {}

local pin_counter = 0
local ord_counter = 0

local function tget(tab, key)
  local ok, v = pcall(vim.api.nvim_tabpage_get_var, tab, key)
  if ok then
    return v
  end
end

local function tset(tab, key, value)
  if value == nil then
    pcall(vim.api.nvim_tabpage_del_var, tab, key)
  else
    pcall(vim.api.nvim_tabpage_set_var, tab, key, value)
  end
end

function M.is_pinned(tab)
  return tget(tab, "pin_seq") ~= nil
end

-- Give every tab a stable ordinal (called lazily so it also covers restored
-- sessions, where tabs come back in the right order but without the var).
local function ensure_ordinals()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if tget(tab, "ordinal") == nil then
      ord_counter = ord_counter + 1
      tset(tab, "ordinal", ord_counter)
    else
      ord_counter = math.max(ord_counter, tget(tab, "ordinal"))
    end
    local ps = tget(tab, "pin_seq")
    if ps then
      pin_counter = math.max(pin_counter, ps)
    end
  end
end

local function desired_order()
  ensure_ordinals()
  local tabs = vim.api.nvim_list_tabpages()
  table.sort(tabs, function(a, b)
    local pa, pb = tget(a, "pin_seq"), tget(b, "pin_seq")
    if pa and pb then
      return pa < pb
    elseif pa then
      return true
    elseif pb then
      return false
    end
    return (tget(a, "ordinal") or 0) < (tget(b, "ordinal") or 0)
  end)
  return tabs
end

-- Physically reorder tab pages to match desired_order() using unambiguous
-- single-step :tabmove commands.
function M.resort()
  if vim.fn.tabpagenr("$") < 2 then
    return
  end
  local rank = {}
  for i, tab in ipairs(desired_order()) do
    rank[tab] = i
  end
  local saved = vim.api.nvim_get_current_tabpage()
  local changed, guard = true, 0
  while changed and guard < 200 do
    changed, guard = false, guard + 1
    local list = vim.api.nvim_list_tabpages()
    for i = 1, #list - 1 do
      if (rank[list[i]] or 0) > (rank[list[i + 1]] or 0) then
        vim.api.nvim_set_current_tabpage(list[i])
        vim.cmd("tabmove +1")
        changed = true
        break
      end
    end
  end
  if vim.api.nvim_tabpage_is_valid(saved) then
    vim.api.nvim_set_current_tabpage(saved)
  end
  vim.cmd("redrawtabline")
end

function M.toggle_pin()
  local tab = vim.api.nvim_get_current_tabpage()
  if M.is_pinned(tab) then
    tset(tab, "pin_seq", nil)
    vim.t.pinned = false
    vim.notify("Tab unpinned")
  else
    pin_counter = pin_counter + 1
    tset(tab, "pin_seq", pin_counter)
    vim.t.pinned = true
    vim.notify("Tab pinned " .. require("icons").pin)
  end
  M.resort()
end

-- Move the current tab one slot within its own group (pinned <-> pinned,
-- unpinned <-> unpinned). Direction: -1 left, 1 right.
function M.move(dir)
  local order = desired_order()
  local cur = vim.api.nvim_get_current_tabpage()
  local idx
  for i, t in ipairs(order) do
    if t == cur then
      idx = i
    end
  end
  if not idx then
    return
  end
  local other = order[idx + dir]
  if not other or M.is_pinned(cur) ~= M.is_pinned(other) then
    return -- edge of the list, or would cross the pinned/unpinned boundary
  end
  local key = M.is_pinned(cur) and "pin_seq" or "ordinal"
  local a, b = tget(cur, key), tget(other, key)
  tset(cur, key, b)
  tset(other, key, a)
  M.resort()
end

function M.close_unpinned()
  local targets = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not M.is_pinned(tab) then
      targets[#targets + 1] = tab
    end
  end
  local closed, kept = 0, 0
  for _, tab in ipairs(targets) do
    if vim.api.nvim_tabpage_is_valid(tab) and vim.fn.tabpagenr("$") > 1 then
      vim.api.nvim_set_current_win(vim.api.nvim_tabpage_get_win(tab))
      if pcall(vim.cmd, "tabclose") then
        closed = closed + 1
      else
        kept = kept + 1
      end
    end
  end
  M.resort()
  vim.notify(
    ("Closed %d unpinned tab(s)"):format(closed) .. (kept > 0 and (", %d kept (unsaved)"):format(kept) or "")
  )
end

-- Keep new tabs after the pinned block.
vim.api.nvim_create_autocmd("TabNewEntered", {
  group = vim.api.nvim_create_augroup("cfg_tabs", { clear = true }),
  callback = function()
    vim.schedule(M.resort)
  end,
})

vim.keymap.set("n", "<leader>bp", M.toggle_pin, { desc = "Pin / unpin tab" })
vim.keymap.set("n", "<leader>bP", M.close_unpinned, { desc = "Close all unpinned tabs" })
vim.keymap.set("n", "<leader>b<", function()
  M.move(-1)
end, { desc = "Move tab left (within group)" })
vim.keymap.set("n", "<leader>b>", function()
  M.move(1)
end, { desc = "Move tab right (within group)" })
vim.keymap.set("n", "[B", function()
  M.move(-1)
end, { desc = "Move tab left" })
vim.keymap.set("n", "]B", function()
  M.move(1)
end, { desc = "Move tab right" })

return M
