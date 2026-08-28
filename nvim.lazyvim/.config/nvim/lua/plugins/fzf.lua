local fzf = require("fzf-lua")
-- local actions = fzf.actions
-- local config = fzf.config
-- config.set_action_helpstr(actions.toggle_ignore, "toggle-ignore")
-- config.set_action_helpstr(actions.toggle_hidden, "toggle-hidden")

return {
  "ibhagwan/fzf-lua",
  opts = {
    files = {
      cmd = "fd --type f --hidden --follow --exclude .git",
      -- cmd = "fd --type f --hidden --no-ignore --follow --exclude .git",
      -- actions = {
      --   ["ctrl-i"] = actions.toggle_ignore,
      --   ["ctrl-h"] = actions.toggle_hidden,
      -- },
    },
    grep = {
      rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --trim",
      -- rg_opts = "--hidden --no-ignore --column --line-number --no-heading --color=always --smart-case --trim",
      -- actions = {
      --   ["ctrl-i"] = actions.toggle_ignore,
      --   ["ctrl-h"] = actions.toggle_hidden,
      -- },
    },
  },
  -- opts = function(_, opts)
  --   local config = fzf.config
  --
  --   opts.files = opts.files or {}
  --   -- opts.files.cmd = "fd --type f --hidden --no-ignore --follow --exclude .git"
  --   opts.files.actions = {
  --     ["ctrl-i"] = actions.toggle_ignore,
  --     ["ctrl-h"] = actions.toggle_hidden,
  --   }
  --
  --   opts.grep = opts.grep or {}
  --   -- opts.grep.rg_opts = "--hidden --no-ignore --column --line-number --no-heading --color=always --smart-case --trim"
  --   opts.grep.actions = {
  --     ["ctrl-i"] = actions.toggle_ignore,
  --     ["ctrl-h"] = actions.toggle_hidden,
  --   }
  --
  --   config.set_action_helpstr(actions.toggle_ignore, "toggle-ignore")
  --   config.set_action_helpstr(actions.toggle_hidden, "toggle-hidden")
  --
  --   return opts
  -- end,
}
