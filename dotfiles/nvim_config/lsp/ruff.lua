return {
  ruff = {
    filetypes = { "python" },
    cmd = { "ruff", "server" },
    init_options = {
      settings = {
        args = {}, -- e.g. { "--preview" }
      },
    },
  },
}
