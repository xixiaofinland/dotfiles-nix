return {
  -- "sainnhe/gruvbox-material",
  -- priority = 1000,
  -- config = function()
  --   vim.o.background = "dark" -- or "light" for light mode
  --   vim.cmd.colorscheme 'gruvbox-material'
  -- end,

  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- day_brightness = 0.9, -- not work?
  },
  config = function()
    vim.cmd [[colorscheme tokyonight-storm]]
    -- colorscheme tokyonight-night
    -- colorscheme tokyonight-storm
    -- colorscheme tokyonight-day
    -- colorscheme tokyonight-moon
  end

  -- "rebelot/kanagawa.nvim",
  -- config = function()
  --   -- setup must be called before loading
  --   vim.cmd("colorscheme kanagawa-wave")
  --   -- vim.cmd("colorscheme kanagawa-dragon")
  --   -- vim.cmd("colorscheme kanagawa-lotus")
  --   vim.api.nvim_set_hl(0, "Visual", {fg='#cc9900', bg='#339966'})
  -- end
}
