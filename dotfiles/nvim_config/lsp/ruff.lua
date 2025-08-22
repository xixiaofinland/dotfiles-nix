return {
  filetypes = { "python" },
  cmd = { "ruff", "server" },  -- ruff-lsp is deprecated
  init_options = {
    settings = {
      args = {}, -- e.g. { "--preview" }
    },
  },
}
