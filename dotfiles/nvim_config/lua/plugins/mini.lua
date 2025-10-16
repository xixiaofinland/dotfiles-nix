return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    config = function()
      local nmap = function(keys, func, desc)
        if desc then
          desc = desc .. ' [Mini]'
        end
        vim.keymap.set('n', keys, func, { desc = desc })
      end

      require('mini.indentscope').setup({
        options = {
          -- indent_at_cursor = false,
          try_as_border = true,
        },
        mappings = {
          goto_top = '[s',
          goto_bottom = ']s',
        }
      })

      local quote_file = vim.fn.expand("~") .. "/.quote"
      local daily_quote = table.concat(vim.fn.readfile(quote_file), "\n") -- daily_quote is refreshed by my Tmux initalization script
      local v = vim.version()
      local ver = string.format('v%s.%s.%s', v.major, v.minor, v.patch)
      local starter = require('mini.starter')
      starter.setup({
        items = {
          { name = '- Nvim ' .. ver, action = '', section = '' },
        },
        footer = daily_quote,
        query_updaters = '',
      })

      require('mini.splitjoin').setup(
        {
          mappings = {
            toggle = '<leader>gp',
          }
        }
      )
      require('mini.indentscope').gen_animation.none()
      require('mini.surround').setup()
      require('mini.trailspace').setup()
      require('mini.doc').setup()
      require('mini.icons').setup()
      require('mini.cursorword').setup()
      require('mini.test').setup()

      require('mini.misc').setup()
      nmap('<leader>l', MiniMisc.zoom, 'toggle large/zoom')
      MiniMisc.setup_restore_cursor({
        ignore_filetype = { "gitcommit", "gitrebase", "SFTerm", "fzf" }
      })

      require('mini.files').setup({
        mappings = {
          close       = '<Esc>',
          go_in       = '<Right>',  -- Right arrow to go into directories
          go_in_plus  = '<CR>',     -- Enter to go in AND open files
          go_out      = '<Left>',   -- Left arrow to go back/up
          go_out_plus = '<S-Left>', -- Shift+Left for go_out_plus
        },

        windows = {
          width_focus = 40,
          preview = true,
          width_preview = 55,
        }
      })

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          local cur_target = MiniFiles.get_explorer_state().target_window
          local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target)
          MiniFiles.go_in({ close_on_file = true })
        end

        local desc = 'Split ' .. direction
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, '<C-s>', 'belowright horizontal')
          map_split(buf_id, '<C-h>', 'belowright vertical')
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesWindowUpdate',
        callback = function(args)
          vim.wo[args.data.win_id].number = true
          vim.wo[args.data.win_id].relativenumber = true
        end,
      })

      -- local set_mark = function(id, path, desc)
      --   MiniFiles.set_bookmark(id, path, { desc = desc })
      -- end
      -- vim.api.nvim_create_autocmd('User', {
      --   pattern = 'MiniFilesExplorerOpen',
      --   callback = function()
      --     set_mark('a', '~/projects/afmt/tests/prettier80/', 'afmt prettier test directory')
      --     set_mark('b', '~/projects/afmt/tests/static/', 'afmt static test directory')
      --     set_mark('c', '~/projects/afmt/tests/comments/', 'afmt comment directory')
      --     set_mark('d', '~/projects/afmt/tests/to-do/', 'afmt static todo directory')
      --   end,
      -- })

      local minifiles_toggle = function()
        if not MiniFiles.close() then
          local current_file = vim.api.nvim_buf_get_name(0)
          local path

          if current_file == '' or current_file:match('^%w+://') then
            -- Use current working directory for special buffers (like Mini.start)
            path = vim.fn.getcwd()
          else
            -- Use current file for normal buffers
            path = current_file
          end

          MiniFiles.open(path)
          MiniFiles.reveal_cwd()
        end
      end
      nmap('<leader>-', minifiles_toggle, 'toggle explorer')

      -- toggle hidden files in mini.files;
      local show_dotfiles = true
      local filter_show = function(fs_entry) return true end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end
      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        MiniFiles.refresh({ content = { filter = new_filter } })
      end
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
        end,
      })

      local gen_spec = require("mini.ai").gen_spec;
      require("mini.ai").setup({
        custom_textobjects = {
          m = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line('$'),
              col = math.max(vim.fn.getline('$'):len(), 1)
            }
            return { from = from, to = to }
          end
        },
      })

      require('mini.bracketed').setup({
        indent     = { suffix = 'i', options = {} },
        comment    = { suffix = 'g', options = {} },

        -- nvim has the default `d`
        diagnostic = { sufeix = '', options = {} },

        -- disabled ones which I don't use;
        location   = { suffix = '', options = {} },
        undo       = { suffix = '', options = {} },
        window     = { suffix = '', options = {} },
      })
      local severity_error = vim.diagnostic.severity.ERROR
      nmap(']l', function() MiniBracketed.diagnostic('forward', { severity = severity_error }) end, 'next error')
      nmap('[l', function() MiniBracketed.diagnostic('backward', { severity = severity_error }) end, 'previous error')

      local hipatterns = require('mini.hipatterns')

      hipatterns.setup({
        highlighters = {
          -- TODO / todo
          todo_upper = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
          todo_lower = { pattern = '%f[%w]()todo()%f[%W]', group = 'MiniHipatternsTodo' },

          -- FIXME / fixme
          fixme_upper = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          fixme_lower = { pattern = '%f[%w]()fixme()%f[%W]', group = 'MiniHipatternsFixme' },

          -- NOTE / note
          note_upper = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
          note_lower = { pattern = '%f[%w]()note()%f[%W]', group = 'MiniHipatternsNote' },

          -- HACK / hack
          hack_upper = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
          hack_lower = { pattern = '%f[%w]()hack()%f[%W]', group = 'MiniHipatternsHack' },

          -- Hex color (#rrggbb)
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      require('mini.bufremove').setup({
        silent = true,
      })

      nmap('<leader>b', require 'mini.bufremove'.delete, 'buffer delete')
      nmap('<leader>ts', MiniTrailspace.trim, 'trim space')
      nmap('<leader>te', MiniTrailspace.trim_last_lines, 'trim end-line')

      local miniclue = require('mini.clue')
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- No leader keys
          { mode = 'n', keys = '\\' },
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
          { mode = 'n', keys = '<C-w>' },
          { mode = 'n', keys = ']' },
          { mode = 'n', keys = '[' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },
        },

        clues = {
          -- for built-in keys
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.z(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          -- miniclue.gen_clues.g(),
        },

        window = {
          delay = 800,
          config = { width = "auto", border = "single" },
        }
      })
    end,
  }
}
