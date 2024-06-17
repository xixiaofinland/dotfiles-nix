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

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Paste without losing the copy' })

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', ']<Space>', ':<C-u>put =repeat(nr2char(10),v:count)<Bar>execute "\'[-1"<CR>',
  { desc = 'Add empty line below', silent = true, noremap = true })
vim.keymap.set('n', '[<Space>', ':<C-u>put!=repeat(nr2char(10),v:count)<Bar>execute "\']+1"<CR>',
  { desc = 'Add empty line above', silent = true, noremap = true })

-- My own habit;

vim.keymap.set('n', '<leader>fn', function() return ':e ' .. vim.fn.expand '%:p:h' .. '/' end,
  { expr = true, desc = 'New a file' })

vim.keymap.set('n', '<leader>cf', function()
  local file_name = vim.fn.expand("%:t")
  vim.fn.setreg('*', file_name)
  vim.notify(string.format('"%s" copied.', file_name), vim.log.levels.INFO)
end, { desc = 'Copy file name' })

vim.keymap.set('n', '<leader>cF', function()
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
  end, { desc = "toggle virtual text" })

vim.keymap.set('n', '<leader>ct',
  function()
    local cmd = 'ctags --extras=+q --langmap=java:.cls.trigger -f ./tags -R **/main/default/classes/**'
    vim.fn.jobstart(cmd, {
      on_exit = function(_, code, _)
        if code == 0 then
          vim.notify("Tags updated successfully.", vim.log.levels.INFO)
        else
          vim.notify("Error updating tags.", vim.log.levels.ERROR)
        end
      end
    })
  end, { noremap = true, silent = true, desc = "generate ctag for Apex" })

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
vim.keymap.set('n', '<leader>,', function() toggle(',') end, { noremap = true, silent = true, desc = 'toggle ","' })
vim.keymap.set('n', '<leader>;', function() toggle(';') end, { noremap = true, silent = true, desc = 'toggle ";"' })

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
vim.keymap.set('n', '\\d', toggleDiagnostics, { noremap = true, silent = true, desc = 'toggle diagnostics' })

-- toggle line num;

local toggleLineNum = function ()
  local current = vim.wo.number
  if current then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end
vim.keymap.set('n', '\\n', toggleLineNum, { noremap = true, silent = true, desc = 'toggle lineNum' })

local opts = { noremap = true, silent = true }

-- Alt + h/j/k/l in insert mode;
vim.keymap.set('i', '<M-h>', '<Left>', opts)
vim.keymap.set('i', '<M-j>', '<Down>', opts)
vim.keymap.set('i', '<M-k>', '<Up>', opts)
vim.keymap.set('i', '<M-l>', '<Right>', opts)

-- insert mode <C-e> delete till end of word;
vim.keymap.set('i', '<C-e>', '<C-o>de', opts)
