return {
  'xixiaofinland/sf.nvim',
  -- branch = 'feature/logs',
  -- dir = '~/projects/sf.nvim',

  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    "ibhagwan/fzf-lua",
  },

  config = function()
    require('sf').setup({
      enable_hotkeys = true,
      auto_display_code_sign = false,
    })

    vim.keymap.set('n', '<leader>e', '<CMD>e ~/.config/nvim/lua/plugins/sf.lua<CR>',
      { desc = 'Open sf config' })

    -- Assuming the afmt binary is placed under path "~"
    local function format_apex()
      local filepath = vim.api.nvim_buf_get_name(0)
      if filepath == "" then
        vim.notify("No file associated with the current buffer.", vim.log.levels.WARN)
        return
      end

      local view = vim.fn.winsaveview()
      vim.cmd('write')

      local afmt_cmd = string.format("~/.local/bin/afmt -w \"%s\"", filepath)
      local result = vim.fn.system(afmt_cmd)

      if vim.v.shell_error == 0 then
        -- vim.notify("Apex code formatted successfully.", vim.log.levels.INFO)

        -- Reload the buffer silently to apply formatting changes
        vim.cmd('silent! edit')

        -- Restore the saved view to maintain cursor position and window state
        vim.fn.winrestview(view)
      else
        vim.notify("Error formatting Apex code:\n" .. result, vim.log.levels.ERROR)
      end
    end

    vim.keymap.set('n', '<leader>al', format_apex,
      { desc = 'afmt format' })
  end
}
