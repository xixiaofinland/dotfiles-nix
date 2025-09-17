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

        vim.keymap.set("n", "<leader>at", function()
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
    config = function()
      require("CopilotChat").setup({
        model = 'claude-sonnet-4',
        prompts = {
          StickyRust = {
            prompt = [[
              > #buffers
              > You are a Rust coding assistant.
              > Always provide clear explanations and reasoning.
              > If a file references other modules, ask me to add them with #file or #glob.
              > Focus on safe Rust practices and idiomatic patterns.
          ]],
            system_prompt =
            'You are a Rust coding assistant that helps me understand and work with Rust code efficiently.',
            description = ''
          },

          StickyApex = {
            prompt = [[
                > #buffers
                > You are an Apex coding assistant.
                > Always provide clear explanations and reasoning.
                > If a class is referenced in the current context but not present in loaded files,
                > tell me explicitly which file you need and ask me to add it using #file or #glob.
                > Focus on Clean Code, Salesforce best practices, Apex idioms, and proper triggers, classes, and test coverage.
              ]],
            system_prompt =
            'You are an Apex assistant that helps me work with classes in Salesforce projects efficiently.',
            description = ''
          }
        }
      });

      vim.keymap.set({ 'n', 'v' }, '<C-e>', '<cmd>CopilotChatStop<CR>',
        { desc = 'Stop chat output' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ao', '<cmd>CopilotChatToggle<CR>',
        { desc = 'Toggle chat window' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ap', '<cmd>CopilotChatPrompts<CR>',
        { desc = 'Select prompt templates' })

      vim.keymap.set({ 'n', 'v' }, '<leader>am', '<cmd>CopilotChatModels<CR>',
        { desc = 'Select chat model' })
    end
  },
}
