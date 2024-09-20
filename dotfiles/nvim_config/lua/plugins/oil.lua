return {
    {
        'stevearc/oil.nvim',

        dependencies = { { "echasnovski/mini.icons", opts = {} } },

        config = function()
            require("oil").setup()
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })
            vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open Oil" })
        end
    }
}
