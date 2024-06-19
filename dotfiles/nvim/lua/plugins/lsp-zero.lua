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

        local servers = {
            apex_ls = {},
            rust_analyzer = {},
            lua_ls = {
                Lua = {
                    workspace = {
                        checkThirdParty = false,
                        library = vim.api.nvim_get_runtime_file("", true)
                    },
                    telemetry = { enable = false },
                    runtime = { version = 'LuaJIT' },
                    diagnostics = {
                        globals = { 'vim' },
                        -- disable = { 'missing-fields' }
                    }
                },
            },
        }

        local zero = require('lsp-zero')
        zero.set_preferences({ call_servers = 'global' })
        zero.extend_lspconfig()
        zero.on_attach(on_attach)

        local lua_ls_config = {
            settings = {
                Lua = {
                    workspace = {
                        checkThirdParty = false,
                        library = vim.api.nvim_get_runtime_file("", true)
                    },
                    diagnostics = { globals = { 'vim' } },
                    runtime = { version = 'LuaJIT' },
                    telemetry = { enable = false },
                },
            },
        }

        zero.configure('lua_ls', lua_ls_config)
        zero.setup_servers(vim.tbl_keys(servers))

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
