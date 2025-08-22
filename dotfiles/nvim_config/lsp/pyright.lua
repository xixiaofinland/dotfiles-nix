return {
  pyright = {
    filetypes = { "python" },
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
  },
}
