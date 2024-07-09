return {
  'MeanderingProgrammer/markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('render-markdown').setup({
      heading = {
        -- icons = { '🌟', '🎉 ', '⚡ ', '💡 ', '🔔 ', '🔮 ' },
        signs = { '' },   -- remove sign icon
        backgrounds = { 'DiffAdd', 'DiffChange'},
      },
      bullet = { icons = { '🔸', '🔹', '✅', '☑️' } },
    })

    vim.api.nvim_set_hl(0, 'markdownH1', { fg = '#00FFFF' })
    vim.api.nvim_set_hl(0, 'markdownH2', { fg = '#00FF00' })
    vim.api.nvim_set_hl(0, 'markdownH3', { fg = '#FFFF00' })

    vim.keymap.set('n', '\\m', require('render-markdown').toggle, { desc = 'markdown' })
  end,
}
