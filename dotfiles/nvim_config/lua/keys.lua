-- General for Nvim

-- Solve two jumping issues using relative line-num in one go:
-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- https://www.reddit.com/r/neovim/comments/1b4xefk/comment/kt5n8xl/
vim.keymap.set('n', 'k', [[(v:count > 1 ? "m'" . v:count : "g") . 'k']], { expr = true })
vim.keymap.set('n', 'j', [[(v:count > 1 ? "m'" . v:count : "g") . 'j']], { expr = true })

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- My own habit;

vim.keymap.set('n', 'H', '^', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>fn', function() return ':e ' .. vim.fn.expand '%:p:h' .. '/' end,
  { expr = true, desc = 'New a file' })

vim.keymap.set('n', '<leader>cn', function()
  local file_name = vim.fn.expand("%:t")
  vim.fn.setreg('*', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, { desc = 'Copy file name' })

vim.keymap.set('n', '<leader>cN', function()
  local file_name = vim.fn.expand("%:p")
  vim.fn.setreg('*', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, { desc = 'Copy File name full path' })

vim.keymap.set("n", "\\v",
  function()
    local curr = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({
      virtual_text = not curr
    })
  end, { desc = "virtual text" })

-- toggle ending ; and ,

local toggle = function(character)
  local api = vim.api
  local delimiters = { ',', ';' }
  local line = api.nvim_get_current_line()
  local last_char = line:sub(-1)

  if last_char == character then
    return api.nvim_set_current_line(line:sub(1, #line - 1))
  elseif vim.tbl_contains(delimiters, last_char) then
    return api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
  else
    return api.nvim_set_current_line(line .. character)
  end
end
vim.keymap.set('n', '<leader>,', function() toggle(',') end, { noremap = true, silent = true, desc = '","' })
vim.keymap.set('n', '<leader>;', function() toggle(';') end, { noremap = true, silent = true, desc = '";"' })

-- toggle diagnostics;

local diag_active = true
local toggleDiagnostics = function()
  diag_active = not diag_active
  if diag_active then
    vim.diagnostic.enable()
    print("Diagnostics enabled")
  else
    vim.diagnostic.enable(false)
    print("Diagnostics disabled")
  end
end
vim.keymap.set('n', '\\d', toggleDiagnostics, { noremap = true, silent = true, desc = 'diagnostics' })

-- toggle line num;

local toggleLineNum = function()
  local current = vim.wo.number
  if current then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end
vim.keymap.set('n', '\\n', toggleLineNum, { noremap = true, silent = true, desc = 'lineNum' })

-- toggle background;

function toggleBackground()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

vim.keymap.set('n', '\\B', toggleBackground, { noremap = true, silent = true, desc = 'background light/dark' })


local opts = { noremap = true, silent = true }

-- Alt + h/j/k/l in insert mode;
vim.keymap.set('i', '<M-h>', '<Left>', opts)
vim.keymap.set('i', '<M-j>', '<Down>', opts)
vim.keymap.set('i', '<M-k>', '<Up>', opts)
vim.keymap.set('i', '<M-l>', '<Right>', opts)

-- insert mode <C-e> delete till end of word;
vim.keymap.set('i', '<C-e>', '<C-o>de', opts)

-- Duplicate a line and comment out the first line
vim.keymap.set('n', 'yc', 'yy<cmd>normal gcc<CR>p')

-- LSP key
vim.keymap.set('n', '<leader>fl', function() vim.lsp.buf.format({ timeout_ms = 2500 }) end,
  { noremap = true, silent = true, desc = 'format file' })

vim.keymap.set('n', 'D', vim.diagnostic.open_float, { noremap = true, silent = true, desc = 'show diagnostic' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true, desc = 'code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true, desc = 'rename' })

-- Obsidian pick files
vim.keymap.set("n", "<leader>nf", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Quick switch notes" })

-- Platform-specific clipboard configuration
vim.opt.clipboard = "unnamedplus"
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
elseif vim.fn.has('mac') == 1 then
  vim.g.clipboard = {
    name = 'macOS-clipboard',
    copy = {
      ['+'] = 'pbcopy',
      ['*'] = 'pbcopy',
    },
    paste = {
      ['+'] = 'pbpaste',
      ['*'] = 'pbpaste',
    },
    cache_enabled = 0,
  }
end

vim.keymap.set('n', '<PageDown>', '<C-d>', { noremap = true })
vim.keymap.set('n', '<PageUp>', '<C-u>', { noremap = true })

vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set({ "i", "v" }, "<C-s>", "<Esc><Cmd>w<CR>")
