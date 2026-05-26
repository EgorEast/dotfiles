-- FIXME: удалить когда обновится LazyVim с учетом обновления этого плагина
return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "lewis6991/async.nvim", -- Добавляем недостающую зависимость
    },
    opts = {},
  },
}
