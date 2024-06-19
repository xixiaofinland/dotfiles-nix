return {
    'VonHeikemen/lsp-zero.nvim',

    dependencies = {
        'neovim/nvim-lspconfig',
        "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
        local on_attach = function(_, bufnr)
            local toggleInlay = function()
                local current_value = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
                vim.lsp.inlay_hint.enable(not current_value, { bufnr = 0 })
            end

            local nmap = function(keys, func, desc)
                if desc then
                    desc = desc .. ' [LSP]'
                end

                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
            end

            nmap('\\i', toggleInlay, 'toggle inlay hint')
            nmap('<leader>rn', vim.lsp.buf.rename, 'rename')
            nmap('<leader>ca', vim.lsp.buf.code_action, 'code action')
            nmap('K', vim.lsp.buf.hover, 'hover doc')
            nmap('D', vim.diagnostic.open_float, 'show diagnostic')

            -- Lesser used LSP functionality
            nmap('gd', vim.lsp.buf.definition, 'goto definition')
            nmap('gD', vim.lsp.buf.declaration, 'goto declaration')
            nmap('<leader>fp', function(_)
                -- So Apex formatting doesn't timeout
                vim.lsp.buf.format({ timeout_ms = 2500 })
            end, 'format file')
        end

        local default_setup_servers = {
            -- apex_ls = {},
            -- lua_ls = {},
            rust_analyzer = {},
        }
        local zero = require('lsp-zero')
        zero.extend_lspconfig()
        zero.on_attach(on_attach)
        zero.setup_servers(vim.tbl_keys(default_setup_servers))

        local lua_opts = zero.nvim_lua_ls()
        require('lspconfig').lua_ls.setup(lua_opts)

        local apex_jar_path = vim.fn.expand('$HOME/apex-jorje-lsp.jar')
        require('lspconfig').apex_ls.setup({
            cmd = {
                "java",
                "-jar",
                apex_jar_path,
            },
            apex_enable_semantic_errors = false,
            apex_enable_completion_statistics = false,
            filetypes = { 'apex' },
        })

        -- zero.setup()

        -- local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- An example for configuring `clangd` LSP to use nvim-cmp as a completion engine
        -- require('lspconfig').clangd.setup {
        --     capabilities = capabilities,
        -- }

        --   function(server_name)
        --     require('lspconfig')[server_name].setup {
        --       capabilities = capabilities,
        --       on_attach = on_attach,
        --       settings = servers[server_name],
        --     }
        --   end,
    end,
}
