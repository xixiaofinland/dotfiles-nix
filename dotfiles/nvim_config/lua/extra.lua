-- TODO: how to get it in lua? This not work: vim.opt.formatoptions = { c = false, r = false, o = false }
-- new line doesn't continue comment
vim.cmd([[autocmd BufEnter * set formatoptions-=cro]])

-- Highlight on yank is supplied by mini.basic already;

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- personal notes;

local note_path = vim.fn.expand("~/notes/")

if vim.loop.fs_stat(note_path) ~= nil then
  local push_cmd = "cd " .. note_path .. "; git add .; git commit -am \"+\"; git push;"
  vim.api.nvim_create_autocmd({ "VimLeave" }, {
    callback = function()
      vim.fn.jobstart(push_cmd, { detach = true })
    end,
  })

  local pull_cmd = "cd " .. note_path .. "; git pull;"
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
      vim.fn.jobstart(pull_cmd, {
        stdout_buffered = true,
        on_exit =
            function(_, code)
              if code == 0 then
                vim.notify('note pull success!', vim.log.levels.INFO)
              else
                vim.notify('note pull failed?', vim.log.levels.ERROR)
              end
            end,
      })
    end,
  })
end

-- LSP;

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set('n', '\\i', function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
    end, { buffer = bufnr, desc = "toggle inlay hints [LSP]" })
  end,
})


-- enter key in quickfix window doesn't jump to the line instead it does nothing.
-- vanila nvim without plugins works as expected
-- I can't find which plugin interferes here, so I add this to overwrite back to default of the enter key
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set('n', '<CR>', '<CR>', { buffer = event.buf, remap = false })
  end,
})
