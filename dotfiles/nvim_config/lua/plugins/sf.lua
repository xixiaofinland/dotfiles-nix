return {
    'xixiaofinland/sf.nvim',
    branch = 'main',
    -- dir = '~/projects/sf.nvim',

    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        "ibhagwan/fzf-lua",
    },

    config = function()
        require('sf').setup({
            enable_hotkeys = true,
        })

        vim.keymap.set('n', '<leader>e', '<CMD>e ~/.config/nvim/lua/plugins/sf.lua<CR>',
            { desc = 'Open sf config' })
    end
}
