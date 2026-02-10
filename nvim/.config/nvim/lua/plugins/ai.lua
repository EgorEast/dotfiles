return {
  {
    "nomnivore/ollama.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    -- All the user commands added by the plugin
    cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

    keys = {
      -- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oo",
        ":<c-u>lua require('ollama').prompt()<cr>",
        desc = "ollama prompt",
        mode = { "n", "v" },
      },

      -- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oG",
        ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
        desc = "ollama Generate Code",
        mode = { "n", "v" },
      },
    },

    ---@type Ollama.Config
    opts = {
      -- your configuration overrides
    },
  },
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
  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
        -- provider = {
        --   enabled = "kitty",
        --   kitty = {
        --     -- ...
        --   },
        -- },
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      local map = vim.keymap.set

      map({ "n", "x" }, "<leader>a", "", { desc = "AI" })
      map({ "n", "x" }, "<leader>ao", "", { desc = "Opencode" })

      -- Recommended/example keymaps.
      map({ "n", "x" }, "<leader>aoa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })
      map({ "n", "x" }, "<leader>aox", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      map({ "n", "t" }, "<leader>ao.", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      map({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Add range to opencode", expr = true })
      map("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      map("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll opencode up" })
      map("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll opencode down" })
    end,
  },

  -- {
  --   "yetone/avante.nvim",
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   -- ⚠️ must add this setting! ! !
  --   build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     or "make",
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   ---@module 'avante'
  --   ---@type avante.Config
  --   opts = {
  --     -- add any opts here
  --     -- this file can contain specific instructions for your project
  --     instructions_file = "avante.md",
  --     -- for example
  --     --     provider = "claude",
  --     --     providers = {
  --     --       claude = {
  --     --         endpoint = "https://api.anthropic.com",
  --     --         model = "claude-sonnet-4-20250514",
  --     --         timeout = 30000, -- Timeout in milliseconds
  --     --         extra_request_body = {
  --     --           temperature = 0.75,
  --     --           max_tokens = 20480,
  --     --         },
  --     --       },
  --     --       moonshot = {
  --     --         endpoint = "https://api.moonshot.ai/v1",
  --     --         model = "kimi-k2-0711-preview",
  --     --         timeout = 30000, -- Timeout in milliseconds
  --     --         extra_request_body = {
  --     --           temperature = 0.75,
  --     --           max_tokens = 32768,
  --     --         },
  --     --       },
  --     --     },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     -- "nvim-mini/mini.pick", -- for file_selector provider mini.pick
  --     -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     "stevearc/dressing.nvim", -- for input provider dressing
  --     "folke/snacks.nvim", -- for input provider snacks
  --     -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     -- "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },
}
