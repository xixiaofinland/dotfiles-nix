return {
  'MeanderingProgrammer/markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('render-markdown').setup({
      heading = {
        icons = { '🌟', '🎉 ', '⚡ ', '💡 ', '🔔 ', '🔮 ' },
        signs = { '' },
        backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
        foregrounds = { 'markdownH1' },
      },
      bullet = { icons = { '🔸', '🔹', '✅', '☑️' } },
    })

    vim.keymap.set('n', '\\m', require('render-markdown').toggle, { desc = 'markdown' })
  end,
}
