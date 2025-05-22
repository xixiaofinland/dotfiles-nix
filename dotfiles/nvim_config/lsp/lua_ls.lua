return {
  capabilities = vim.lsp.protocol.make_client_capabilities(),

  -- cmd = {'lua-language-server'},
  -- filetypes = {'lua'},
  -- root_markers = {'.luarc.json', '.luarc.jsonc'},

  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

