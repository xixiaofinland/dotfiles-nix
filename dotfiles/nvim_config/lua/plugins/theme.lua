return {
  -- "folke/tokyonight.nvim",
  -- lazy = false,
  -- priority = 1000,
  -- config = function()
  --   require("tokyonight").setup({
  --     style = "strom",
  --     terminal_colors = true,
  --     day_brightness = 0.2,
  --     dim_inactive = true,
  --     -- transparent = true,
  --   })
  --   vim.cmd.colorscheme("tokyonight-storm")
  --   -- colorscheme tokyonight-night
  --   -- colorscheme tokyonight-storm
  --   -- colorscheme tokyonight-day
  --   -- colorscheme tokyonight-moon
  -- end

  -- "rebelot/kanagawa.nvim",
  -- config = function()
  --   require('kanagawa').setup({
  --     dimInactive = true, -- dim inactive window `:h hl-NormalNC`
  --   })
  --
  --   -- setup must be called before loading
  --   vim.cmd("colorscheme kanagawa-wave")
  --   -- vim.cmd("colorscheme kanagawa-dragon")
  --   -- vim.cmd("colorscheme kanagawa-lotus")
  --   vim.api.nvim_set_hl(0, "Visual", { fg = '#cc9900', bg = '#339966' })
  -- end

  'ribru17/bamboo.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('bamboo').setup {}
    require('bamboo').load()
  end
}
