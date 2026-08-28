-- Git change indicators in the sign column. This is the one thing Neovim has no
-- native equivalent for, so mini.diff (single-purpose, dependency-free) is used.
-- Everything else git-related is native: :DiffTool, :Undotree, and a lazygit
-- terminal float (see term.lua).
local gi = require("icons").git
local ok, minidiff = pcall(require, "mini.diff")
if ok then
  minidiff.setup({
    view = {
      style = "sign",
      signs = { add = gi.added, change = gi.changed, delete = gi.removed },
    },
    mappings = {
      apply = "gh",
      reset = "gH",
      textobject = "gh",
      goto_prev = "[h",
      goto_next = "]h",
    },
  })

  vim.keymap.set("n", "<leader>g", "", { desc = "Git" })
  vim.keymap.set("n", "<leader>gd", minidiff.toggle_overlay, { desc = "Git: toggle diff overlay" })
  vim.keymap.set("n", "<leader>gD", "<cmd>DiffTool<cr>", { desc = "Git: native diff tool" })
  vim.keymap.set("n", "<leader>gu", "<cmd>Undotree<cr>", { desc = "Undo tree (native)" })
end

-- Cache the current branch in a buffer variable for the statusline.
local branch_group = vim.api.nvim_create_augroup("cfg_git_branch", { clear = true })
local function update_branch(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local dir = vim.fs.dirname(name)
  vim.system(
    { "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" },
    { text = true },
    function(res)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          local branch = vim.trim(res.stdout or "")
          vim.b[buf].git_branch = (res.code == 0 and branch ~= "" and branch ~= "HEAD") and branch or nil
        end
      end)
    end
  )
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  group = branch_group,
  callback = function(ev)
    update_branch(ev.buf)
  end,
})
