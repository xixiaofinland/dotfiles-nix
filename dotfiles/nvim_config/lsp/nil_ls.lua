return {
  filetypes = { "nix" },
  root_markers = {'flake.nix', '.git'},
  -- root_dir = vim.fs.dirname(vim.fs.find({ "flake.nix", "shell.nix", ".git" }, { upward = true })[1]),
  settings = {
    ["nil"] = {
      formatting = {
        command = { 'alejandra' },
      },
    },
  },
}
