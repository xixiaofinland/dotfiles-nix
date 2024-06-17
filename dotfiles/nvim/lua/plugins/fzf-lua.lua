return {
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup({
                defaults = {
                    formatter = "path.filename_first",
                    path_shorten = 5,
                }
            })

            local nmap = function(keys, func, desc)
                if desc then
                    desc = desc .. ' [Fzf]'
                end
                vim.keymap.set('n', keys, func, { desc = desc })
            end

            local create_ctags = function()
                -- need to install universial ctags;
                local cmd = 'ctags --extras=+q --langmap=java:.cls.trigger -f ./tags -R **/main/default/classes/**'
                vim.fn.jobstart(cmd, {
                    on_exit = function(_, code, _)
                        if code == 0 then
                            vim.notify("Tags updated successfully.", vim.log.levels.INFO)
                        else
                            vim.notify("Error updating tags.", vim.log.levels.ERROR)
                        end
                    end
                })
            end

            local fzf = require('fzf-lua')

            -- fzf.register_ui_select()

            nmap('<leader>ff', fzf.files, 'files')
            nmap('<leader>fr', fzf.resume, 'resume')
            nmap('<leader>fd', fzf.diagnostics_document, 'diagnostics')
            nmap('<leader>fD', function() fzf.files({ cwd = vim.fn.stdpath 'config' }) end, 'dotfiles')
            nmap('<leader>fb', fzf.buffers, 'buffers')
            nmap('<leader>.', fzf.oldfiles, 'recent files')
            nmap('<leader>fg', fzf.grep, 'grep')
            nmap('<leader>fw', fzf.grep_cword, 'word in project')
            nmap('<leader>fW', fzf.grep_cWORD, 'word in current')
            nmap("<leader>fm", fzf.lsp_document_symbols, 'method list')
            nmap('<leader>/', fzf.grep_curbuf, 'search current buffer')
            nmap('<leader>fc', fzf.command_history, 'command history')
            nmap('<leader>fh', fzf.helptags, 'help')
            nmap('<leader>gf', fzf.git_files, 'git files')
            nmap('<leader>gc', fzf.git_commits, 'git commits')
            nmap('<leader>gC', fzf.git_bcommits, 'git commits this buffer')
            nmap('<leader>gb', fzf.git_branches, 'git branches')

            nmap('<leader>ft', function()
                create_ctags()
                fzf.tags()
            end, 'ctag in project')


            -- need to install zoxide
            nmap('<leader>z', function()
                fzf.fzf_exec("zoxide query -ls", {
                    prompt = 'Set cwd() > ',
                    actions = {
                        ['default'] = function(selected)
                            local dir = selected[1]:match("([^%s]+)$")
                            vim.fn.chdir(dir)
                        end
                    }
                })
            end, 'z setup cwd')

            vim.keymap.set('x', '<leader>fv', fzf.grep_visual, { desc = 'visual grep [Fzf]' })
        end
    }
}
