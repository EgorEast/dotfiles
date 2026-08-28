return {
  "MeanderingProgrammer/render-markdown.nvim",
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    completions = { enabled = true, lsp = { enabled = true }, blink = { enabled = true } },
    enabled = true,
    checkbox = {
      enabled = true,
      right_pad = 6,
      unchecked = {
        -- Replaces '[ ]' of 'task_list_marker_unchecked'.
        icon = "󰄱",
        -- Highlight for the unchecked icon.
        highlight = "RenderMarkdownUnchecked",
        -- Highlight for item associated with unchecked checkbox.
        scope_highlight = nil,
      },
      checked = {
        -- Replaces '[x]' of 'task_list_marker_checked'.
        icon = "",
        -- Highlight for the checked icon.
        highlight = "RenderMarkdownChecked",
        -- Highlight for item associated with checked checkbox.
        scope_highlight = "@markup.strikethrough",
      },
      custom = {
        followup = {
          raw = "[>]",
          rendered = "",
          highlight = "RenderMarkdownBullet",
          scope_highlight = nil,
        },
        canceled = {
          raw = "[~]",
          rendered = "󰰱",
          highlight = "RenderMarkdownTableHead",
          scope_highlight = nil,
        },
        warning = {
          raw = "[!]",
          rendered = "",
          highlight = "RenderMarkdownError",
          scope_highlight = nil,
        },
        todo = {
          raw = "[-]",
          rendered = "󰥔",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
      },
    },
    heading = {
      enabled = true,
      render_modes = false,
      atx = true,
      setext = true,
      sign = false,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      position = "overlay",
      signs = { "󰫎 " },
      width = "full",
      left_margin = 0,
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = false,
      border_virtual = false,
      border_prefix = false,
      above = "▄",
      below = "▀",
      backgrounds = {
        "RenderMarkdownH1Bg",
        "RenderMarkdownH2Bg",
        "RenderMarkdownH3Bg",
        "RenderMarkdownH4Bg",
        "RenderMarkdownH5Bg",
        "RenderMarkdownH6Bg",
      },
      foregrounds = {
        "RenderMarkdownH1",
        "RenderMarkdownH2",
        "RenderMarkdownH3",
        "RenderMarkdownH4",
        "RenderMarkdownH5",
        "RenderMarkdownH6",
      },
      custom = {},
    },
    code = {
      enabled = true,
      render_modes = false,
      sign = true,
      style = "full",
      position = "left",
      language_pad = 2,
      language_icon = false,
      language_name = false,
      disable_background = { "diff" },
      width = "full",
      left_margin = 0,
      left_pad = 2,
      right_pad = 0,
      min_width = 0,
      border = "thick",
      above = "▄",
      below = "▀",
      inline_left = "",
      inline_right = "",
      inline_pad = 0,
      highlight = "RenderMarkdownCode",
      highlight_language = nil,
      highlight_border = "RenderMarkdownCodeBorder",
      highlight_fallback = "RenderMarkdownCodeFallback",
      highlight_inline = "RenderMarkdownCodeInline",
    },
    dash = {
      enabled = true,
      render_modes = false,
      icon = "─",
      width = "full",
      left_margin = 0,
      highlight = "RenderMarkdownDash",
    },
    bullet = {
      enabled = true,
      render_modes = false,
      icons = { "", "", "◆", "◇" },
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ("%d."):format(index > 1 and index or ctx.index)
      end,
      left_pad = 1,
      right_pad = 1,
      highlight = "RenderMarkdownBullet",
      scope_highlight = {},
    },
    quote = {
      -- Turn on / off block quote & callout rendering.
      enabled = true,
      -- Additional modes to render quotes.
      render_modes = false,
      -- Replaces '>' of 'block_quote'.
      icon = "▋",
      -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text
      -- if incorrectly configured with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'.
      -- A combination of these that is likely to work follows.
      -- | showbreak      | '  ' (2 spaces)   |
      -- | breakindent    | true              |
      -- | breakindentopt | '' (empty string) |
      -- These are not validated by this plugin. If you want to avoid adding these to your main
      -- configuration then set them in win_options for this plugin.
      repeat_linebreak = false,
      -- Highlight for the quote icon.
      -- If a list is provided output is evaluated by `cycle(value, level)`.
      highlight = {
        "RenderMarkdownQuote1",
        "RenderMarkdownQuote2",
        "RenderMarkdownQuote3",
        "RenderMarkdownQuote4",
        "RenderMarkdownQuote5",
        "RenderMarkdownQuote6",
      },
    },
    link = {
      -- Turn on / off inline link icon rendering.
      enabled = true,
      -- Additional modes to render links.
      render_modes = false,
      -- How to handle footnote links, start with a '^'.
      footnote = {
        -- Turn on / off footnote rendering.
        enabled = true,
        -- Replace value with superscript equivalent.
        superscript = true,
        -- Added before link content.
        prefix = "",
        -- Added after link content.
        suffix = "",
      },
      -- Inlined with 'image' elements.
      image = "󰥶 ",
      -- Inlined with 'email_autolink' elements.
      email = "󰀓 ",
      -- Fallback icon for 'inline_link' and 'uri_autolink' elements.
      hyperlink = "󰌹 ",
      -- Applies to the inlined icon as a fallback.
      highlight = "RenderMarkdownLink",
      -- Applies to WikiLink elements.
      wiki = {
        icon = "󱗖 ",
        body = function()
          return nil
        end,
        highlight = "RenderMarkdownWikiLink",
      },
      -- Define custom destination patterns so icons can quickly inform you of what a link
      -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
      -- patterns match a link the one with the longer pattern is used.
      -- The key is for healthcheck and to allow users to change its values, value type below.
      -- | pattern   | matched against the destination text                            |
      -- | icon      | gets inlined before the link text                               |
      -- | kind      | optional determines how pattern is checked                      |
      -- |           | pattern | @see :h lua-patterns, is the default if not set       |
      -- |           | suffix  | @see :h vim.endswith()                                |
      -- | priority  | optional used when multiple match, uses pattern length if empty |
      -- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
      custom = {
        web = { pattern = "^http", icon = "󰖟 " },
        discord = { pattern = "discord%.com", icon = "󰙯 " },
        github = { pattern = "github%.com", icon = "󰊤 " },
        gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
        google = { pattern = "google%.com", icon = "󰊭 " },
        neovim = { pattern = "neovim%.io", icon = " " },
        reddit = { pattern = "reddit%.com", icon = "󰑍 " },
        stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
        wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
        youtube = { pattern = "youtube%.com", icon = "󰗃 " },
      },
      sign = {
        enabled = true,
        highlight = "RenderMarkdownSign",
      },
    },
    file_types = { "markdown", "vimwiki" },
  },
}
