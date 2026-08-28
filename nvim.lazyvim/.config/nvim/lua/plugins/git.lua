return {
  {
    "rbong/vim-flog",
    dependencies = {
      "tpope/vim-fugitive",
    },
    lazy = true,
    keys = {
      { "<leader>gF", ":Flog<cr>", desc = "Flog" },
    },
  },
  {
    "sindrets/diffview.nvim",
    lazy = true,
    keys = {
      { "<leader>gD", ":DiffviewOpen<cr>", desc = "Diffview" },
      { "<leader>gF", "<Esc>:'<,'>DiffviewFileHistory<cr>", mode = { "x" }, desc = "Diffview File History" },
      { "<leader>gF", ":DiffviewFileHistory %<cr>", desc = "Diffview File History" },
    },
  },
}
