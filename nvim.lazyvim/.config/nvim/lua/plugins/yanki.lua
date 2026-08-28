return {
  "gbprod/yanky.nvim",
  opts = {},
  keys = {
    {
      "<leader>y",
      function()
        Snacks.picker.yanky()
      end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
  },
}
