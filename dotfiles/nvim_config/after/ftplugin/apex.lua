vim.opt_local.textwidth = 0 -- legacy code has long width and doesn't use prettier

-- Enable treesitter-context automatically for apex
require("treesitter-context").enable()

-- Disable diagnostics in Apex
vim.diagnostic.enable(false)

-- Jump to function names
vim.keymap.set('n', '[m', function()
  require 'nvim-treesitter.textobjects.move'.goto_previous_start("@function.name")
end, { buffer = true, desc = "ts: prev function name" })

vim.keymap.set('n', ']m', function()
  require 'nvim-treesitter.textobjects.move'.goto_next_start("@function.name")
end, { buffer = true, desc = "ts: next function name" })
