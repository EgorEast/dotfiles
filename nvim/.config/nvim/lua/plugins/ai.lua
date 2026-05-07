return {
  {
    "nomnivore/ollama.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    -- All the user commands added by the plugin
    cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

    keys = {
      {
        "<leader>al",
        "",
        desc = "Ollama",
        mode = { "n", "v" },
      },
      {
        "<leader>alg",
        ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
        desc = "Ollama Generate Code",
        mode = { "n", "v" },
      },
      {
        "<leader>alp",
        ":<c-u>lua require('ollama').prompt()<cr>",
        desc = "Ollama prompt",
        mode = { "n", "v" },
      },
    },

    ---@type Ollama.Config
    opts = {
      -- your configuration overrides
    },
  },
  -- {
  --   "Exafunction/windsurf.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  --   config = function()
  --     require("codeium").setup({ virtual_text = { enabled = true } })
  --   end,
  -- },
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
      {
        -- `snacks.nvim` integration is recommended, but optional
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = { keys = { ["<a-a>"] = { "opencode_send", mode = { "n", "i" } } } },
            },
          },
          terminal = {}, -- Enables the `snacks` provider
        },
      },
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

      vim.o.autoread = true -- Required for `opts.events.reload`.

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

      require("lualine").setup({
        sections = {
          lualine_z = {
            {
              require("opencode").statusline,
            },
          },
        },
      })
    end,
  },
}
