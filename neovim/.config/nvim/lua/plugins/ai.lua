-- local map = vim.keymap.set
-- map("n", "<leader>a", "", { desc = "AI" })

return {
  {
    "joshuavial/aider.nvim",
    opts = {
      -- your configuration comes here
      -- if you don't want to use the default settings
      auto_manage_context = true, -- automatically manage buffer context
      default_bindings = true, -- use default <leader>A keybindings
      debug = false, -- enable debug logging
    },
  },
  -- https://github.com/GeorgesAlkhouri/nvim-aider
  -- {
  --   "GeorgesAlkhouri/nvim-aider",
  --   cmd = {
  --     "AiderTerminalToggle",
  --     "AiderHealth",
  --   },
  --   keys = {
  --     { "<leader>aa", "", desc = "Aider" },
  --     { "<leader>aa/", ":AiderTerminalToggle<cr>", desc = "Open Aider" },
  --     { "<leader>aas", ":AiderTerminalSend<cr>", desc = "Send to Aider", mode = { "n", "v" } },
  --     { "<leader>aac", ":AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
  --     { "<leader>aab", ":AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
  --     { "<leader>aa+", ":AiderQuickAddFile<cr>", desc = "Add File to Aider" },
  --     { "<leader>aa-", ":AiderQuickDropFile<cr>", desc = "Drop File from Aider" },
  --     { "<leader>aar", ":AiderQuickReadOnlyFile<cr>", desc = "Add File as Read-Only" },
  --     -- Example nvim-tree.lua integration if needed
  --     { "<leader>aa+", ":AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
  --     { "<leader>aa-", ":AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
  --   },
  --   dependencies = { "folke/snacks.nvim" },
  -- },
  -- https://github.com/sourcegraph/sg.nvim
  -- {
  --   "sourcegraph/sg.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   config = function()
  --     -- Sourcegraph configuration. All keys are optional
  --     require("sg").setup({})
  --   end,
  -- },
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        virtual_text = {
          enabled = true,
        },
      })
    end,
  },
  -- https://github.com/jackMort/ChatGPT.nvim
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   keys = {
  --     { "<leader>ag", ":ChatGPT<cr>", desc = "Open ChatGPT" },
  --   },
  --   config = function()
  --     require("chatgpt").setup()
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim", -- optional
  --     "nvim-telescope/telescope.nvim",
  --   },
  -- },
  -- https://github.com/u3ih/gemini.nvim?ysclid=m8coek9gzf44878956
  -- {
  --   "gera2ld/ai.nvim",
  --   dependencies = "nvim-lua/plenary.nvim",
  --   opts = {
  --     ---- AI's answer is displayed in a popup buffer
  --     ---- Default behaviour is not to give it the focus because it is seen as a kind of tooltip
  --     ---- But if you prefer it to get the focus, set to true.
  --     result_popup_gets_focus = false,
  --     ---- Override default prompts here, see below for more details
  --     -- prompts = {},
  --     ---- Default models for each prompt, can be overridden in the prompt definition
  --     models = {
  --       {
  --         provider = "deepseek",
  --         model = "deepseek-r1",
  --         result_tpl = "## DeepSeek\n\n{{output}}",
  --       },
  --       -- {
  --       --   provider = "gemini",
  --       --   model = "gemini-pro",
  --       --   result_tpl = "## Gemini\n\n{{output}}",
  --       -- },
  --       -- {
  --       --   provider = "openai",
  --       --   model = "gpt-3.5-turbo",
  --       --   result_tpl = "## GPT-3.5\n\n{{output}}",
  --       -- },
  --     },
  --
  --     --- API keys and relavant config
  --     -- gemini = {
  --     --   api_key = "YOUR_GEMINI_API_KEY",
  --     --   -- model = 'gemini-pro',
  --     --   -- proxy = '',
  --     -- },
  --     -- openai = {
  --     --   api_key = "YOUR_OPENAI_API_KEY",
  --     --   -- base_url = 'https://api.openai.com/v1',
  --     --   -- model = 'gpt-4',
  --     --   -- proxy = '',
  --     -- },
  --   },
  --   config = function()
  --     local ai = require("ai")
  --     local ok, opts = pcall(vim.fn.json_decode, os.getenv("AI_NVIM_PROVIDER_CONFIG"))
  --     opts = ok and opts or {}
  --     ai.setup(opts)
  --   end,
  --   event = "VeryLazy",
  -- },
}
