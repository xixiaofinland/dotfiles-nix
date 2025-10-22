return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local none_ls = require("null-ls")
    local formatting = none_ls.builtins.formatting

    none_ls.setup({
      sources = {
        -- Nix formatter
        formatting.alejandra,

        -- Python formatter
        formatting.black,

        -- formatting.prettier.with({
        --   filetypes = { "apex" },
        --   extra_args = { "--plugin=prettier-plugin-apex", "--write" },
        -- }),

        -- note: for apex format in `prettired`, make sure .prettierrc has this section below
        -- "plugins": [
        --   "prettier-plugin-apex",
        -- ],
        formatting.prettierd.with({
          filetypes = { "apex", "html", "javascript", "typescript", "markdown", "yaml", "css", "scss", "less", "json" },
        }),

        -- PMD diagnostics for Apex
        none_ls.builtins.diagnostics.pmd.with({
          command = "pmd",
          filetypes = { "apex" },
          args = function(params)
            return {
              "-f", "json", -- JSON output for null-ls to parse
              "-R", "apex_ruleset.xml",
              "--no-cache",
              "-d", params.bufname, -- only check this file
            }
          end,
        }),

        -- none_ls.builtins.diagnostics.pmd.with({
        --   -- pmd v6
        --   filetypes = { "apex" },
        --   extra_args = { "--rulesets", "apex_ruleset.xml" },
        --
        --   -- -- pmd v7 needs to define the wrapper (ref: https://github.com/nvimtools/none-ls.nvim/issues/47)
        --   -- -- #!/usr/bin/env bash
        --   -- -- path/to/pmd/bin/pmd check "$@"
        --   -- filetypes = { "apex" },
        --   -- args = { "--format", "json", "--dir", "$ROOT", "--rulesets", "apex_ruleset.xml", "--no-cache", "--no-progress" }
        -- }),
      },
    })
  end,
}
