return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  cmd = { "ObsidianQuickSwitch" }, -- globally avail
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
      enable = false,
      -- update_debounce = 200,
      -- max_file_length = 5000,
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)
    -- vim.opt.conceallevel = 2

    -- pick links in the current note
    vim.keymap.set("n", "<leader>nl", "<cmd>ObsidianLinks<cr>", { desc = "Pick links" })

    -- Create or open link
    vim.keymap.set("v", "<leader>nn", "<cmd>ObsidianLinkNew<CR>", { desc = "Open or create link" })

    -- Create or open link from word under cursor
    vim.keymap.set("n", "<leader>nn", function()
      vim.cmd('normal! viw')
      vim.cmd('ObsidianLinkNew')
    end, { desc = "Create link from word under cursor" })

    -- Pick Backlinks
    vim.keymap.set("n", "<leader>nb", "<cmd>ObsidianBacklinks<CR>", { desc = "Pick backlinks" })
  end,
}
