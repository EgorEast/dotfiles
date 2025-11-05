-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local title = vim.fn.expand("%:t:r") -- Название файла (без .md)

    -- Пропускаем, если заголовок уже есть
    for _, line in ipairs(lines) do
      if line:match("^# ") then
        return
      end
    end

    -- Ищем конец фронтматтера (вторые `---`)
    local frontmatter_end = 0
    local dashes_seen = 0
    for i, line in ipairs(lines) do
      if line:match("^---") then
        dashes_seen = dashes_seen + 1
        if dashes_seen == 2 then
          frontmatter_end = i
          break
        end
      end
    end

    -- Если фронтматтер есть (нашли два `---`), вставляем заголовок после него
    if frontmatter_end > 0 then
      -- Проверяем, что после фронтматтера нет заголовка
      local next_line = lines[frontmatter_end + 1] or ""
      if not next_line:match("^# ") then
        vim.api.nvim_buf_set_lines(
          buf,
          frontmatter_end,
          frontmatter_end,
          false,
          { "", "# " .. title, "" } -- Добавляем с отступами
        )
      end
    else
      -- Если фронтматтера нет, добавляем заголовок в начало
      if #lines == 0 or not lines[1]:match("^# ") then
        vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "# " .. title, "" })
      end
    end
  end,
})
