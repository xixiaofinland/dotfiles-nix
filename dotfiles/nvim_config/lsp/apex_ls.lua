return {
  cmd = {
    "java",
    "-jar",
    vim.fn.expand("$HOME/apex-jorje-lsp.jar"),
  },
  filetypes = { "apex" },
  root_markers = { 'sfdx-project.json', '.git' },
  settings = {
    apex = {
      apex_enable_semantic_errors = false,
      apex_enable_completion_statistics = false,
    },
  },
}
