return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "MeanderingProgrammer/markdown.nvim",
  },
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

    -- picker links in the current note
    vim.keymap.set("n", "<leader>of", "<cmd>ObsidianLinks<cr>", { desc = "Pick links" })

    -- Create or open link
    vim.keymap.set("v", "<leader>on", "<cmd>ObsidianLinkNew<CR>", { desc = "Open or create link" })

    -- Create or open link from word under cursor
    vim.keymap.set("n", "<leader>on", function()
      vim.cmd('normal! viw')
      vim.cmd('ObsidianLinkNew')
    end, { desc = "Create link from word under cursor" })

    -- Pick Backlinks
    vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Pick backlinks" })
  end,
}
