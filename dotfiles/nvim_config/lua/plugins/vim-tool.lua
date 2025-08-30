return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      disable_mouse = false,
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
        ["<Left>"] = false,
        ["<Right>"] = false,
      },
    }
  },

  vim.keymap.set('n', '\\h', function()
    vim.cmd('Hardtime toggle')
  end, { noremap = true, silent = true, desc = 'hard-time' }),
}
