-- https://github.com/epwalsh/obsidian.nvim
return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "ObsidianOpen",
    "ObsidianNew",
    "ObsidianQuickSwitch",
    "ObsidianFollowLink",
    "ObsidianBacklinks",
    "ObsidianTags",
    "ObsidianToday",
    "ObsidianYesterday",
    "ObsidianTomorrow",
    "ObsidianDailies",
    "ObsidianTemplate",
    "ObsidianSearch",
    "ObsidianLink",
    "ObsidianLinkNew",
    "ObsidianLinks",
    "ObsidianExtractNote",
    "ObsidianWorkspace",
    "ObsidianPasteImg",
    "ObsidianRename",
    "ObsidianToggleCheckbox",
    "ObsidianNewFromTemplate",
    "ObsidianTOC",
  },
  keys = {
    { "<leader>o", "", mode = { "n", "x" }, desc = "Obsidian" },
    { "<leader>ob", ":ObsidianBacklinks<CR>", mode = { "n", "x" }, desc = "Backlinks" }, -- :ObsidianBacklinks for getting a picker list of references to the current buffer.
    { "<leader>oc", ":ObsidianToggleCheckbox<CR>", mode = { "n", "x" }, desc = "Toggle checkbox" }, -- :ObsidianToggleCheckbox to cycle through checkbox options.
    { "<leader>od", "", mode = { "n", "x" }, desc = "Daily notes" }, -- :ObsidianToday for getting a picker list of all notes created today.
    { "<leader>odt", ":ObsidianToday<CR>", mode = { "n", "x" }, desc = "Today" }, -- :ObsidianToday for getting a picker list of all notes created today.
    { "<leader>ody", ":ObsidianYesterday<CR>", mode = { "n", "x" }, desc = "Yesterday" }, -- :ObsidianYesterday for getting a picker list of all notes created yesterday.
    { "<leader>odT", ":ObsidianTomorrow<CR>", mode = { "n", "x" }, desc = "Tomorrow" }, -- :ObsidianTomorrow for getting a picker list of all notes created tomorrow.
    { "<leader>odd", ":ObsidianDailies<CR>", mode = { "n", "x" }, desc = "Dailies" }, -- :ObsidianDailies for getting a picker list of all daily notes.
    { "<leader>oe", ":ObsidianExtractNote<CR>", mode = { "n", "x" }, desc = "Extract note" }, -- :ObsidianExtractNote [TITLE] to extract the visually selected text into a new note and link to it.
    { "<leader>of", ":ObsidianFollowLink<CR>", mode = { "n", "x" }, desc = "Follow link" }, -- :ObsidianFollowLink [vsplit|hsplit] to follow a note reference under the cursor, optionally opening it in a vertical or horizontal split.
    { "<leader>oi", ":ObsidianPasteImg<CR>", mode = { "n", "x" }, desc = "Paste image" }, -- :ObsidianPasteImg [IMGNAME] to paste an image from the clipboard into the note at the cursor position by saving it to the vault and adding a markdown image link. You can configure the default folder to save images to with the attachments.img_folder option.
    { "<leader>ol", "", mode = { "n", "x" }, desc = "Links" }, -- :ObsidianLinks to collect all links within the current buffer into a picker window.
    { "<leader>olL", ":ObsidianLinks<CR>", mode = { "n", "x" }, desc = "Links list" }, -- :ObsidianLinks to collect all links within the current buffer into a picker window.
    { "<leader>oll", ":ObsidianLink<CR>", mode = { "n", "x" }, desc = "Link" }, -- :ObsidianLink [QUERY] to link an inline visual selection of text to a note. This command has one optional argument: a query that will be used to resolve the note by ID, path, or alias. If not given, the selected text will be used as the query.
    { "<leader>oln", ":ObsidianLinkNew<CR>", mode = { "n", "x" }, desc = "Link New" }, -- :ObsidianLinkNew [TITLE] to create a new note and link it to an inline visual selection of text. This command has one optional argument: the title of the new note. If not given, the selected text will be used as the title.
    { "<leader>on", ":ObsidianNew<CR>", mode = { "n", "x" }, desc = "New note" }, -- :ObsidianNew [TITLE] to create a new note. This command has one optional argument: the title of the new note.
    { "<leader>oN", ":ObsidianNewFromTemplate<CR>", mode = { "n", "x" }, desc = "New note from template" }, -- :ObsidianNewFromTemplate [TITLE] to create a new note from a template in the templates folder. Selecting from a list using your preferred picker. This command has one optional argument: the title of the new note.
    { "<leader>oo", ":ObsidianOpen<CR>", mode = { "n", "x" }, desc = "Open in app" }, -- :ObsidianOpen [QUERY] to open a note in the Obsidian app. This command has one optional argument: a query used to resolve the note to open by ID, path, or alias. If not given, the note corresponding to the current buffer is opened.
    { "<leader>oO", ":ObsidianTOC<CR>", mode = { "n", "x" }, desc = "Table of contents" }, -- :ObsidianTOC to load the table of contents of the current note into a picker list.
    { "<leader>oq", ":ObsidianQuickSwitch<CR>", mode = { "n", "x" }, desc = "Quick switch" }, -- :ObsidianQuickSwitch to quickly switch to (or open) another note in your vault, searching by its name using ripgrep with your preferred picker (see plugin dependencies below).
    { "<leader>or", ":ObsidianRename<CR>", mode = { "n", "x" }, desc = "Rename" }, -- :ObsidianRename [NEWNAME] [--dry-run] to rename the note of the current buffer or reference under the cursor, updating all backlinks across the vault. Since this command is still relatively new and could potentially write a lot of changes to your vault, I highly recommend committing the current state of your vault (if you're using version control) before running it, or doing a dry-run first by appending "--dry-run" to the command, e.g. :ObsidianRename new-id --dry-run.
    { "<leader>os", ":ObsidianSearch<CR>", mode = { "n", "x" }, desc = "Search" }, -- :ObsidianSearch [QUERY] to search for (or create) notes in your vault using ripgrep with your preferred picker.
    { "<leader>ot", ":ObsidianTags<CR>", mode = { "n", "x" }, desc = "Tags" }, -- :ObsidianTags [TAG ...] for getting a picker list of all occurrences of the given tags.
    { "<leader>oT", ":ObsidianTemplate<CR>", mode = { "n", "x" }, desc = "Template" }, -- :ObsidianTemplate [TEMPLATE] to create a new note using a template from the templates folder.
    { "<leader>ow", ":ObsidianWorkspace<CR>", mode = { "n", "x" }, desc = "Workspace" }, -- :ObsidianWorkspace [NAME] to switch to another workspace.
  },

  ----@type obsidian.config.ClientOpts
  opts = {
    workspaces = {
      {
        name = "obsidian",
        path = "~/Yandex.Disk/Obsidian",
        overrides = {
          attachments = {
            img_folder = "Исходники",
          },
          templates = {
            folder = "Шаблоны",
          },
          daily_notes = {
            folder = "Работа/Отчеты",
            default_tags = {},
            -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
            template = "Отчет в чат КРЭЛКОМ",
          },
        },
      },
      {
        name = "buf-parent",
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
      },
    },
    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = "current_dir",

    daily_notes = {
      folder = "daily-notes",
      default_tags = {},
      -- Optional, if you want to change the date format for the ID of daily notes.
      -- date_format = "%d-%m-%Y",
      date_format = "%Y.%m.%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = nil,
    },

    -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      -- ["<leader>ch"] = {
      --   action = function()
      --     return require("obsidian").util.toggle_checkbox()
      --   end,
      --   opts = { buffer = true },
      --   desc = "Toggle checkbox",
      -- },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },

    -- Optional, for templates (see below).
    templates = {
      folder = "templates",
      date_format = "%Y.%m.%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },

    -- Optional, set to true if you use the Obsidian Advanced URI plugin.
    -- https://github.com/Vinzent03/obsidian-advanced-uri
    use_advanced_uri = true,

    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "wiki",

    -- Optional, boolean or a function that takes a filename and returns a boolean.
    -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
    disable_frontmatter = false,

    -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
    open_app_foreground = false,

    -- Optional, sort search results by "path", "modified", "accessed", or "created".
    -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
    -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
    sort_by = "modified",
    sort_reversed = true,

    -- Set the maximum number of lines to read from notes on disk when performing certain searches.
    search_max_lines = 1000,

    -- Optional, determines how certain commands open notes. The valid options are:
    -- 1. "current" (the default) - to always open in the current window
    -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
    -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
    open_notes_in = "current",

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      -- return tostring(os.time()) .. "-" .. suffix
      return suffix
    end,

    -- Optional, customize how note file names are generated given the ID, target directory, and title.
    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    ---@return string|obsidian.Path The full path to the new note.
    note_path_func = function(spec)
      -- This is equivalent to the default behavior.
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix(".md")
    end,

    -- Optional, customize how wiki links are formatted. You can set this to one of:
    --  * "use_alias_only", e.g. '[[Foo Bar]]'
    --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
    --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
    --  * "use_path_only", e.g. '[[foo-bar.md]]'
    -- Or you can set it to a function that takes a table of options and returns a string, like this:
    wiki_link_func = function(opts)
      -- return require("obsidian.util").wiki_link_id_prefix(opts)
      return require("obsidian.util").wiki_link_alias_only(opts)
    end,

    -- Optional, customize how markdown links are formatted.
    markdown_link_func = function(opts)
      return require("obsidian.util").markdown_link(opts)
    end,

    -- Optional, alternatively you can customize the frontmatter data.
    ---@param note obsidian.Note
    ---@return table
    note_frontmatter_func = function(note)
      -- Add the title of the note as an alias.
      -- if note.title then
      --   note:add_alias(note.title)
      -- end

      -- local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      local out = {}

      if next(note.aliases) ~= nil then
        out.aliases = note.aliases
      end

      if next(note.tags) ~= nil then
        out.tags = note.tags
      end

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      -- vim.fn.jobstart({ "open", url }) -- Mac OS
      -- vim.fn.jobstart({ "xdg-open", url }) -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      vim.ui.open(url) -- need Neovim 0.10.0+
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
    -- file it will be ignored but you can customize this behavior here.
    ---@param img string
    follow_img_func = function(img)
      -- vim.fn.jobstart({ "qlmanage", "-p", img }) -- Mac OS quick look preview
      vim.fn.jobstart({ "xdg-open", img }) -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    end,

    -- -- Optional, define your own callbacks to further customize behavior.
    -- callbacks = {
    --   -- Runs at the end of `require("obsidian").setup()`.
    --   ---@param client obsidian.Client
    --   post_setup = function(client) end,
    --
    --   -- Runs anytime you enter the buffer for a note.
    --   ---@param client obsidian.Client
    --   ---@param note obsidian.Note
    --   enter_note = function(client, note) end,
    --
    --   -- Runs anytime you leave the buffer for a note.
    --   ---@param client obsidian.Client
    --   ---@param note obsidian.Note
    --   leave_note = function(client, note) end,
    --
    --   -- Runs right before writing the buffer for a note.
    --   ---@param client obsidian.Client
    --   ---@param note obsidian.Note
    --   pre_write_note = function(client, note) end,
    --
    --   -- Runs anytime the workspace is set/changed.
    --   ---@param client obsidian.Client
    --   ---@param workspace obsidian.Workspace
    --   post_set_workspace = function(client, workspace) end,
    -- },

    -- Specify how to handle attachments.
    attachments = {
      img_folder = "attachments/images",
      -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
      ---@return string
      img_name_func = function()
        -- Prefix image names with timestamp.
        return string.format("%s-", os.time())
      end,

      -- A function that determines the text to insert in the note when pasting an image.
      -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
      -- This is the default implementation.
      ---@param client obsidian.Client
      ---@param path obsidian.Path the absolute path to the image file
      ---@return string
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![[%s]]", path.name, path)
      end,
    },
  },
}
