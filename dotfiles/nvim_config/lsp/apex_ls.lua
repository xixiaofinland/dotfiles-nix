return {
  cmd = {
    "java",
    "-jar",
    vim.fn.expand("$HOME/apex-jorje-lsp.jar"),
  },
  filetypes = { "apex" },
  settings = {
    apex = {
      apex_enable_semantic_errors = false,
      apex_enable_completion_statistics = false,
    },
  },
}
