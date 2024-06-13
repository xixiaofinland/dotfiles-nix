return {
  {
    'rust-lang/rust.vim',
    ft = "rust",
    init = function()
      -- autoformat in save
      vim.g.rustfmt_autosave = 1
    end
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
  },
}
