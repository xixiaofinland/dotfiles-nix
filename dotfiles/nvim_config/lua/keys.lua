-- General for Nvim

local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

-- Navigate wildmenu with up/down arrows
vim.keymap.set('c', '<Down>', function()
  return vim.fn.wildmenumode() == 1 and '<Right>' or '<Down>'
end, { expr = true })

vim.keymap.set('c', '<Up>', function()
  return vim.fn.wildmenumode() == 1 and '<Left>' or '<Up>'
end, { expr = true })

-- Solve two jumping issues using relative line-num in one go:
-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- https://www.reddit.com/r/neovim/comments/1b4xefk/comment/kt5n8xl/
vim.keymap.set('n', 'k', [[(v:count > 1 ? "m'" . v:count : "g") . 'k']], { expr = true })
vim.keymap.set('n', 'j', [[(v:count > 1 ? "m'" . v:count : "g") . 'j']], { expr = true })

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

nmap("J", "mzJ`z", nil)
nmap("n", "nzzzv", nil)
nmap("N", "Nzzzv", nil)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- My own habit;

-- C-v is the paste action in my alacritty, so use this for square cursor
nmap("<C-b>", "<C-v>", nil)

vim.keymap.set('n', '<leader>hn', function() return ':e ' .. vim.fn.expand '%:p:h' .. '/' end,
  { expr = true, desc = 'New a file' })

nmap('<leader>hc', function()
  local file_name = vim.fn.expand("%:t")
  vim.fn.setreg('+', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, 'Copy file name')

nmap('<leader>hC', function()
  local file_name = vim.fn.expand("%:p")
  vim.fn.setreg('+', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, 'Copy File name full path')

nmap("\\v", function()
  local curr = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({
    virtual_text = not curr
  })
end, "virtual text")

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
nmap('<leader>,', function() toggle(',') end, '","')
nmap('<leader>;', function() toggle(';') end, '";"')

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
nmap('\\d', toggleDiagnostics, 'diagnostics')

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
nmap('\\n', toggleLineNum, 'lineNum')

-- insert mode <C-e> delete till end of word;
vim.keymap.set('i', '<C-e>', '<C-o>de', { silent = true })

-- Duplicate a line and comment out the first line
nmap('yp', 'yy<cmd>normal gcc<CR>p', nil)

-- LSP key
nmap('<leader>ff', function() vim.lsp.buf.format({ timeout_ms = 2500 }) end, 'format file')

nmap('L', vim.diagnostic.open_float, 'show diagnostic')
nmap('H', vim.lsp.buf.hover, 'LSP hover doc')

nmap('<leader>ca', vim.lsp.buf.code_action, 'code action')
nmap('<leader>rn', vim.lsp.buf.rename, 'rename')

-- Close all floating windows
nmap('<Esc>', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end, 'Close floating windows')

-- Save and quit
nmap('##', ':x<CR>', 'Save and quit')

-- Quit without saving
nmap('QQ', ':q!<CR>', 'Force quit')

-- Obsidian pick files
nmap("<leader>nf", "<cmd>Obsidian quick_switch<cr>", "Quick switch notes")

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

nmap('<PageDown>', '<C-d>', nil)
nmap('<PageUp>', '<C-u>', nil)

nmap("<C-s>", "<Cmd>w<CR>", nil)
vim.keymap.set({ "i", "v" }, "<C-s>", "<Esc><Cmd>w<CR>")

nmap("<PageUp>", "<C-u>zz", nil)
nmap("<PageDown>", "<C-d>zz", nil)

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
nmap('<leader>mp', ':mark p<CR>', nil)
nmap('<leader>md', ':mark d<CR>', nil)
nmap('<leader>mn', ':mark n<CR>', nil)

-- display LSPs like :LspInfo

nmap("<leader>pl", function()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, c.name)
  end
  print("Attached LSPs: " .. table.concat(names, ", "))
end, 'List active LSPs')

nmap("<leader>pL", "<Cmd>check vim.lsp<CR>", 'List detaild LSPs')

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap('[p', '<Cmd>exe "put! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "put "  . v:register<CR>', 'Paste Below')
