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

        local zero = require('lsp-zero')
        zero.extend_lspconfig()
        zero.on_attach(on_attach)

        local lang_servers = {
            apex_ls = {
                cmd = {
                    "java",
                    "-jar",
                    vim.fn.expand('$HOME/apex-jorje-lsp.jar'),
                },
                apex_enable_semantic_errors = false,
                apex_enable_completion_statistics = false,
                filetypes = { 'apex' },
            },
            lua_ls = zero.nvim_lua_ls(),
            nil_ls = {},
            rust_analyzer = {},
        }

        for _, lsp in ipairs(vim.tbl_keys(lang_servers)) do
            require('lspconfig')[lsp].setup(lang_servers[lsp])
        end

        -- local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- local lua_opts = {
        --     settings = {
        --         Lua = {
        --             workspace = {
        --                 checkThirdParty = false,
        --                 -- Setting changes. Ref: https://www.reddit.com/r/neovim/comments/1dmvou4/lua_lang_server_scans_too_many_files/
        --                 -- library = vim.api.nvim_get_runtime_file("", true),
        --                 -- ignoreDir = { '.direnv' }
        --             },
        --             telemetry = { enable = false },
        --             diagnostics = {
        --                 globals = { 'vim' },
        --                 -- disable = { 'missing-fields' }
        --             }
        --         }
        --     }
        -- };
    end,
}
