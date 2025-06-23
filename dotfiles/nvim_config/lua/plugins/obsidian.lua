return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "MeanderingProgrammer/markdown.nvim",
  },
  ---@module 'obsidian'
  ---@type obsidian.config.ClientOpts
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/notes/personal",
      },
      {
        name = "work",
        path = "~/notes/work",
      },
    },
    completion = {
      nvim_cmp = false, -- disable nvim-cmp
      blink = true,     -- enable blink.cmp
      min_chars = 2,
    },
    -- daily_notes = {
    --   folder = "daily",
    --   date_format = "%Y-%m-%d",
    -- },
    -- templates = {
    --   subdir = "templates",
    --   date_format = "%Y-%m-%d",
    --   time_format = "%H:%M",
    -- },
    note_frontmatter_func = function(_)
      return {
        -- tags = {},
      }
    end,

    note_id_func = function(title)
      return title -- makes filename = title.md
    end,
    ui = {
      enable = true, -- enable UI features including concealment
      update_debounce = 200,
      max_file_length = 5000,
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)
    vim.opt.conceallevel = 2

    -- Follow link under cursor
    -- vim.keymap.set("n", "<leader>og", "<cmd>ObsidianFollowLink<CR>", { desc = "Follow link" })

    -- picker links in the current note
    vim.keymap.set("n", "<leader>of", "<cmd>ObsidianLinks<cr>", { desc = "Pick links" })

    -- picker notes
    -- vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Pick notes" })

    -- Create or open link from word under cursor
    vim.keymap.set("n", "<leader>on", function()
      vim.cmd('normal! viw')
      vim.cmd('ObsidianLinkNew')
    end, { desc = "Create link from word under cursor" })

    -- Create or open link
    vim.keymap.set("v", "<leader>on", "<cmd>ObsidianLinkNew<CR>", { desc = "Open or create link" })

    -- Pick Backlinks
    vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Pick backlinks" })
  end,
}
