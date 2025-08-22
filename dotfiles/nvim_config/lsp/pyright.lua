return {
  filetypes = { "python" },
  cmd = { "pyright-langserver", "--stdio" },
  root_markers = { "pyproject.toml", "requirements.txt", "setup.cfg", "setup.py", "ruff.toml", ".git", },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "standard", -- "off" | "basic" | "standard" | "strict"
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
      },
      venvPath = ".",
      venv = ".venv",
    },
  },
}
