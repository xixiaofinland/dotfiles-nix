return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context'
  },
  build = ':TSUpdate',
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "apex", "bash", "haskell", "nix", "rust", "soql", "sosl", "lua", "vim", "vimdoc", "markdown" },
      auto_install = true,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,

          keymaps = {
            ["l="] = { query = "@assignment.lhs", desc = "ts: left assignment" },
            ["r="] = { query = "@assignment.rhs", desc = "ts: right assignment" },
            -- ["aa"] = { query = "@parameter.outer", desc = "ts: outer parameter" },
            -- ["ia"] = { query = "@parameter.inner", desc = "ts: inner parameter" },
            -- ["am"] = { query = "@function.outer", desc = "ts: outer function" },
            -- ["im"] = { query = "@function.inner", desc = "ts: inner function" },
            -- ["ai"] = { query = "@conditional.outer", desc = "ts: outer conditional" },
            -- ["ii"] = { query = "@conditional.inner", desc = "ts: inner conditional" },

            -- ["a="] = { query = "@assignment.outer", desc = "ts: outer assignment" },
            -- ["i="] = { query = "@assignment.inner", desc = "ts: inner ssignment" },
            -- ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
            -- ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
            -- ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
            -- ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },
            -- ["al"] = { query = "@loop.outer", desc = "ts: outer loop" },
            -- ["il"] = { query = "@loop.inner", desc = "ts: inner loop" },
            -- ["af"] = { query = "@call.outer", desc = "ts: outer function-call" },
            -- ["if"] = { query = "@call.inner", desc = "ts: inner function-call" },
            -- ["ac"] = { query = "@class.outer", desc = "ts: outer class" },
            -- ["ic"] = { query = "@class.inner", desc = "ts: inner class" },
          },
        },

        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = { query = "@function.outer", desc = "ts: next def method/function start" },
            ["]a"] = { query = "@parameter.inner", desc = "ts: next def method/function start" },
            -- ["]c"] = { query = "@class.outer", desc = "ts: next class start" },
            -- ["]i"] = { query = "@conditional.outer", desc = "ts: next conditional start" },
            -- ["]l"] = { query = "@loop.outer", desc = "next loop start" },
            -- ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            -- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]M"] = { query = "@function.outer", desc = "ts: next def method/function end" },
            -- ["]C"] = { query = "@class.outer", desc = "ts: next class end" },
            -- ["]I"] = { query = "@conditional.outer", desc = "ts: next conditional end" },
            -- ["]L"] = { query = "@loop.outer", desc = "ts: next loop end" },
          },
          goto_previous_start = {
            ["[m"] = { query = "@function.outer", desc = "ts: prev def method/function start" },
            ["[a"] = { query = "@parameter.inner", desc = "ts: next def method/function start" },
            -- ["[c"] = { query = "@class.outer", desc = "ts: prev class start" },
            -- ["[i"] = { query = "@conditional.outer", desc = "ts: prev conditional start" },
            -- ["[l"] = { query = "@loop.outer", desc = "ts: prev loop start" },
          },
          goto_previous_end = {
            ["[M"] = { query = "@function.outer", desc = "ts: prev def method/function end" },
            -- ["[C"] = { query = "@class.outer", desc = "ts: prev class end" },
            -- ["[I"] = { query = "@conditional.outer", desc = "ts: prev conditional end" },
            -- ["[L"] = { query = "@loop.outer", desc = "ts: prev loop end" },
          },
        },

        swap = {
          enable = true,
          swap_next = {
            ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
            ["<leader>nm"] = "@function.outer",  -- swap function with next
            -- ["<leader>n:"] = "@property.outer",    -- swap object property with next
          },
          swap_previous = {
            ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
            ["<leader>pm"] = "@function.outer",  -- swap function with previous
            -- ["<leader>p:"] = "@property.outer",  -- swap object property with prev
          },
        },
      },
    })
  end,
}
