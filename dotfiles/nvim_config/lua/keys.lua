-- General for Nvim

-- Solve two jumping issues using relative line-num in one go:
-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- https://www.reddit.com/r/neovim/comments/1b4xefk/comment/kt5n8xl/
vim.keymap.set('n', 'k', [[(v:count > 1 ? "m'" . v:count : "g") . 'k']], { expr = true })
vim.keymap.set('n', 'j', [[(v:count > 1 ? "m'" . v:count : "g") . 'j']], { expr = true })

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- My own habit;

-- C-v is the paste action in my alacritty, so use this for square cursor
vim.keymap.set("n", "<C-b>", "<C-v>")

vim.keymap.set('n', '<leader>hn', function() return ':e ' .. vim.fn.expand '%:p:h' .. '/' end,
  { expr = true, desc = 'New a file' })

vim.keymap.set('n', '<leader>hc', function()
  local file_name = vim.fn.expand("%:t")
  vim.fn.setreg('+', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, { desc = 'Copy file name' })

vim.keymap.set('n', '<leader>hC', function()
  local file_name = vim.fn.expand("%:p")
  vim.fn.setreg('+', file_name)
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
vim.keymap.set('n', '<leader>,', function() toggle(',') end, { silent = true, desc = '","' })
vim.keymap.set('n', '<leader>;', function() toggle(';') end, { silent = true, desc = '";"' })

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
vim.keymap.set('n', '\\d', toggleDiagnostics, { silent = true, desc = 'diagnostics' })

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
vim.keymap.set('n', '\\n', toggleLineNum, { silent = true, desc = 'lineNum' })

-- insert mode <C-e> delete till end of word;
vim.keymap.set('i', '<C-e>', '<C-o>de', { silent = true })

-- Duplicate a line and comment out the first line
vim.keymap.set('n', 'yp', 'yy<cmd>normal gcc<CR>p')

-- LSP key
vim.keymap.set('n', '<leader>ff', function() vim.lsp.buf.format({ timeout_ms = 2500 }) end,
  { silent = true, desc = 'format file' })

vim.keymap.set('n', 'L', vim.diagnostic.open_float, { silent = true, desc = 'show diagnostic' })
vim.keymap.set('n', 'H', vim.lsp.buf.hover, { silent = true, desc = 'LSP hover doc' })

vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { silent = true, desc = 'code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { silent = true, desc = 'rename' })

-- Close all floating windows
vim.keymap.set('n', '<Esc>', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { silent = true, desc = 'Close floating windows' })

-- Save and quit
vim.keymap.set('n', '##', ':x<CR>', { silent = true, desc = 'Save and quit' })

-- Quit without saving
vim.keymap.set('n', 'QQ', ':q!<CR>', { silent = true, desc = 'Force quit' })

-- Obsidian pick files
vim.keymap.set("n", "<leader>nf", "<cmd>Obsidian quick_switch<cr>", { desc = "Quick switch notes" })

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

vim.keymap.set('n', '<PageDown>', '<C-d>')
vim.keymap.set('n', '<PageUp>', '<C-u>')

vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set({ "i", "v" }, "<C-s>", "<Esc><Cmd>w<CR>")

vim.keymap.set("n", "<PageUp>", "<C-u>zz")
vim.keymap.set("n", "<PageDown>", "<C-d>zz")

vim.keymap.set("n", "^", function()
  if vim.fn.col('.') == 1 then
    return '^'
  else
    local first_non_blank = vim.fn.match(vim.fn.getline('.'), '\\S') + 1
    if vim.fn.col('.') == first_non_blank then
      return '0'
    else
      return '^'
    end
  end
end, { expr = true, desc = "Smart start-of-line" })

-- marks
vim.keymap.set('n', '<leader>mp', ':mark p<CR>')
vim.keymap.set('n', '<leader>md', ':mark d<CR>')
vim.keymap.set('n', '<leader>mn', ':mark n<CR>')

-- display LSPs like :LspInfo

vim.keymap.set("n", "<leader>pl", function()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, c.name)
  end
  print("Attached LSPs: " .. table.concat(names, ", "))
end, { desc = 'List active LSPs' })

vim.keymap.set("n", "<leader>pL", "<Cmd>check vim.lsp<CR>", { desc = 'List detaild LSPs' })
