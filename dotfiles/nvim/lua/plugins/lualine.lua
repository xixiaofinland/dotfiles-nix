return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local function sf_status()
      local target_org = require('sf').get_target_org()
      local covered_percent = require('sf').covered_percent()
      return target_org .. "(" .. covered_percent .. ")"
    end

    require('lualine').setup {
      options = {
        icons_enabled = false,
        -- theme = 'gruvbox',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        -- lualine_b = { 'branch' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename', sf_status },
        lualine_x = { 'encoding', 'filetype' },
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      }
    }
  end
}
