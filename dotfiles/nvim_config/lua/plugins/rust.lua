return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ["rust-analyzer"] = {
              -- checkOnSave = { command = "clippy" },
              files = {
                watcher = "client", -- default "server" doesn't work in macOS
              },
            },
          },
        },
      }
    end,
  }
}
