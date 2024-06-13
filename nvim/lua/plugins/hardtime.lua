return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      disable_mouse = false,
    }
  },

  {
    "tris203/precognition.nvim",
    config = {
      startVisible = false,
    }
  },

  vim.keymap.set('n', '\\h', function()
    vim.cmd('Hardtime toggle')
  end, { noremap = true, silent = true, desc = 'toggle hard-time' }),

  vim.keymap.set('n', '\\p', function()
    require("precognition").toggle()
  end, { noremap = true, silent = true, desc = 'toggle precognition' })
}
