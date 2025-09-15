return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local actions = require "fzf-lua.actions"

      require("fzf-lua").setup({
        defaults = {
          file_icons = "mini",
          formatter = "path.filename_first",
          path_shorten = 5,
        },
        actions = {
          files = {
            true,
            -- ["default"] = actions.file_edit_or_qf,
            -- ["ctrl-s"]  = actions.file_split,
            ["ctrl-e"]  = actions.file_vsplit,
          }
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
      fzf.register_ui_select()

      nmap('<leader>hh', fzf.files, 'files')
      nmap('<leader>hr', fzf.resume, 'resume')
      nmap('<leader>hd', fzf.diagnostics_document, 'diagnostics')
      -- nmap('<leader>fD', function() fzf.files({ cwd = vim.fn.stdpath 'config' }) end, 'dotfiles')
      nmap('<leader>hb', fzf.buffers, 'buffers')
      nmap('<leader>.', fzf.oldfiles, 'recent files')
      nmap('<leader>hg', fzf.grep, 'grep')
      nmap('<leader>hw', fzf.grep_cword, 'word in project')
      nmap('<leader>hW', fzf.grep_cWORD, 'word in current')
      nmap("<leader>hm", function()
          fzf.lsp_document_symbols({
            regex_filter = function(item, _)
              local kind = item.kind
              return kind == "Struct" or kind == "Enum" or kind == "Method" or kind == "Function"
            end
          })
        end,
        'Lsp Meth/Fn/Struct/Enum')
      -- nmap("<leader>fM", fzf.lsp_document_symbols, 'lsp docs')
      nmap("<leader>hM", fzf.lsp_workspace_symbols, 'workspace symbols')
      nmap('<leader>/', fzf.grep_curbuf, 'search current buffer')
      nmap('<leader>fc', fzf.command_history, 'command history')
      nmap('<leader>fh', fzf.helptags, 'help')
      nmap('<leader>gf', fzf.git_files, 'git files')
      nmap('<leader>gc', fzf.git_commits, 'git commits')
      nmap('<leader>gC', fzf.git_bcommits, 'git commits this buffer')
      nmap('<leader>gb', fzf.git_branches, 'git branches')
      nmap("<leader>gr", function()
        fzf.lsp_references({
          jump1 = true,
          ignore_current_line = true,
          ignoreDecleration = true,
        })
      end, 'reference')

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
