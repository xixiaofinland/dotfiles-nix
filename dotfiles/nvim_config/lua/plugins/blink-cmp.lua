return {
  'saghen/blink.cmp',
  dependencies = { 'fang2hou/blink-copilot', 'archie-judd/blink-cmp-words' },
  version = '*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = { preset = 'default' },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'dictionary', 'copilot' },
      providers = {
        lsp = {
          -- Overwrite the default (fallbacks = {'buffer'}) which diables buffer source when lsp is available
          -- I want to have buffer source available all the time.
          fallbacks = {}
        },
        buffer = {
          score_offset = -1, -- increase, default was -3
        },
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          async = true,
        },
        dictionary = {
          name = "blink-cmp-words",
          module = "blink-cmp-words.dictionary",
          opts = {
            -- The number of characters required to trigger completion.
            dictionary_search_threshold = 5,
            score_offset = -5,
            definition_pointers = { "!", "&", "^" },
          },
        },
      },
      menu = {
        -- use mini icons
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            }
          }
        }
      }
    },

    cmdline = {
      enabled = false
    },
  },
  opts_extend = { "sources.default" }
}
