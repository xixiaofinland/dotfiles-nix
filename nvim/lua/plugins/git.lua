return {
  {
    'sindrets/diffview.nvim',
    config = function()
      vim.keymap.set('n', '<leader>hv', vim.cmd.DiffviewOpen, { desc = 'open diff window' })
      vim.keymap.set('n', '<leader>hc', vim.cmd.DiffviewClose, { desc = 'close diff window' })
    end
  },

  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
    end
  },

  'tpope/vim-rhubarb',

  {
    'lewis6991/gitsigns.nvim', -- See `:help gitsigns.txt`
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[h', require('gitsigns').prev_hunk, { buffer = bufnr, desc = 'previous hunk' })
        vim.keymap.set('n', ']h', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'next hunk' })

        vim.keymap.set('n', '<leader>hh', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = 'preview hunk' })
        vim.keymap.set('n', '<leader>hs', require('gitsigns').stage_hunk,
          { buffer = bufnr, desc = 'stage hunk' })
        vim.keymap.set('n', '<leader>hu', require('gitsigns').undo_stage_hunk,
          { buffer = bufnr, desc = 'undo stage hunk' })
        vim.keymap.set('n', '<leader>hS', require('gitsigns').stage_buffer,
          { buffer = bufnr, desc = 'stage buffer' })
        vim.keymap.set('n', '\\b', require('gitsigns').toggle_current_line_blame,
          { buffer = bufnr, desc = 'toggle blame' })
      end,
    },
  }
}
