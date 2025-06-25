return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local none_ls = require("null-ls")
    none_ls.setup({
      sources = {
        none_ls.builtins.formatting.alejandra,

        none_ls.builtins.formatting.prettier.with({
          filetypes = { "apex" },
          extra_args = { "--plugin=prettier-plugin-apex", "--write" },
        }),

        none_ls.builtins.formatting.prettier.with({
          filetypes = { "html", "javascript" },
        }),

        none_ls.builtins.diagnostics.pmd.with({
          -- pmd v6
          filetypes = { "apex" },
          extra_args = { "--rulesets", "apex_ruleset.xml", },

          -- -- pmd v7 needs to define the wrapper (ref: https://github.com/nvimtools/none-ls.nvim/issues/47)
          -- -- #!/usr/bin/env bash
          -- -- path/to/pmd/bin/pmd check "$@"
          -- filetypes = { "apex" },
          -- args = { "--format", "json", "--dir", "$ROOT", "--rulesets", "apex_ruleset.xml", "--no-cache", "--no-progress" }
        }),
      }
    })
  end,
}
