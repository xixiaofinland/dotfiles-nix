return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          layout = {
            position = "right",
          }
        },
        suggestion = {
          enabled = false, --I use fang2hou/blink-copilot instead

        },
        should_attach = function(_, _)
          -- Always return false to prevent automatic attachment
          return false
        end,

        vim.keymap.set("n", "<leader>act", function()
          local client = require("copilot.client")
          if client.buf_is_attached(0) then
            require("copilot.command").detach()
            vim.notify("Copilot detached from buffer", vim.log.levels.INFO)
          else
            require("copilot.command").attach({ force = true })
            vim.notify("Copilot attached to buffer", vim.log.levels.INFO)
          end
        end, {
          desc = "Toggle Copilot LSP",
        })
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken",                          -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
