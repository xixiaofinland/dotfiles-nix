vim.opt_local.textwidth = 0 -- legacy code has long width and doesn't use prettier

-- Enable treesitter-context automatically for apex
require("treesitter-context").enable()

-- Disable diagnostics in Apex
vim.diagnostic.enable(false)
