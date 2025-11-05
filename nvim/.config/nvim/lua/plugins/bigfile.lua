return {
  {
    "ouuan/nvim-bigfile",
    opts = {
      -- Default size limit in bytes
      size_limit = 5 * 1024 * 1024, -- 5MB

      -- Per-filetype size limits
      ft_size_limits = {
        -- javascript = 100 * 1024, -- 100KB for javascript files
      },

      -- Show notifications when big files are detected
      notification = true,

      -- Enable basic syntax highlighting (not TreeSitter) for big files
      -- (tips: it will be automatically disabled if too slow)
      syntax = true,

      -- Custom additional hook function to run when big files are detected
      hook = nil,
      -- hook = function(buf, ft)
      --   vim.b.minianimate_disable = true
      -- end,
    },
  },
  -- {
  --   "LunarVim/bigfile.nvim",
  -- },
}
