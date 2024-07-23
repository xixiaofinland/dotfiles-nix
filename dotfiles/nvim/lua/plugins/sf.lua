return {
    'xixiaofinland/sf.nvim',
    branch = 'pre-release',
    -- dir = '~/projects/sf.nvim',

    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        "ibhagwan/fzf-lua",
    },

    config = function()
        require('sf').setup()

        vim.keymap.set('n', '<leader>e', '<CMD>e ~/.config/nvim/lua/plugins/sf.lua<CR>',
            { desc = 'Open sf config' })
    end
}
