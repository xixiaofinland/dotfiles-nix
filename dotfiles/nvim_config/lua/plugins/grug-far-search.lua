return {
    'MagicDuck/grug-far.nvim',
    config = function()
        require('grug-far').setup();

        local nmap = function(keys, func, desc)
            if desc then
                desc = desc .. ' [grug]'
            end
            vim.keymap.set('n', keys, func, { desc = desc })
        end

        local grup = require('grug-far')
        nmap('<leader>rg', ':GrugFar<CR>', 'grug open')
        nmap('<leader>rw', function()
            grup.grug_far({ prefills = { search = vim.fn.expand("<cword>") } })
        end, 'grug current word')
    end
}
