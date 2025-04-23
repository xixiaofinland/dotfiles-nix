return {
  "NStefan002/screenkey.nvim",
  lazy = false,
  branch = 'dev',
  config = function()
    vim.keymap.set('n', '\\k', ':Screenkey<CR>', { noremap = true, silent = true, desc = 'screenkey' })
  end
}
