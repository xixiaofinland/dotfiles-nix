return {
  "rebelot/kanagawa.nvim",
  config = function()
    require('kanagawa').setup({
      dimInactive = true, -- dim inactive window `:h hl-NormalNC`
    })

    vim.cmd("colorscheme kanagawa-wave")
    -- vim.cmd("colorscheme kanagawa-dragon")
    -- vim.cmd("colorscheme kanagawa-lotus")
    vim.api.nvim_set_hl(0, "Visual", { fg = '#cc9900', bg = '#339966' })
  end
}
