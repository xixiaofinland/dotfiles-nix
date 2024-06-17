vim.api.nvim_buf_set_keymap(0, 'i', '<M-i>', ' = ', { noremap = true })

-- Use custom comment leaders to allow both nested variants (`--` and `----`)
-- and "docgen" variant (`---`).
vim.cmd([[setlocal comments=:---,:--]])

vim.opt_local.expandtab = true
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
