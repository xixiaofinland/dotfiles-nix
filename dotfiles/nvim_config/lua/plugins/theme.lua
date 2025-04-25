-- TO-TRY:
-- https://github.com/bluz71/vim-moonfly-colors
-- https://github.com/bluz71/vim-nightfly-colors
-- https://github.com/EdenEast/nightfox.nvim

return {
  {
    {
      "bluz71/vim-nightfly-colors",
      name = "nightfly",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd("colorscheme nightfly")
      end
    },
  },
  -- {
  --   "bluz71/vim-moonfly-colors",
  --   name = "moonfly",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd("colorscheme moonfly")
  --   end
  -- },
  -- {
  --   "rebelot/kanagawa.nvim",
  --   config = function()
  --     require('kanagawa').setup({
  --       dimInactive = true, -- dim inactive window `:h hl-NormalNC`
  --     })
  --
  --     vim.cmd("colorscheme kanagawa-wave")
  --     -- vim.cmd("colorscheme kanagawa-dragon")
  --     -- vim.cmd("colorscheme kanagawa-lotus")
  --     vim.api.nvim_set_hl(0, "Visual", { fg = '#cc9900', bg = '#339966' })
  --   end
  -- }
}
