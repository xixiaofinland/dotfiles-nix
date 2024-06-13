return {
  "nvimtools/none-ls.nvim", -- configure formatters & linters
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "apex" },
          extra_args = { "--plugin=prettier-plugin-apex", "--write" },
        }),

        null_ls.builtins.diagnostics.pmd.with({
          -- pmd v7 needs to define the wrapper (ref: https://github.com/nvimtools/none-ls.nvim/issues/47)
          -- #!/usr/bin/env bash
          -- path/to/pmd/bin/pmd check "$@"

          filetypes = { "apex" },
          args = { "--format", "json", "--dir", "$ROOT", "--rulesets", "apex_ruleset.xml", "--no-cache", "--no-progress" }
        }),
      }
    })
  end,
}
