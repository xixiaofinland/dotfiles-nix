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

local function open_note(name)
  -- local buffers = vim.fn.getbufinfo({ bufloaded = true })
  -- if (#buffers == 1 and buffers[1].name == "") or (#buffers == 2 and string.find(buffers[1].name, "Starter") and string.find(buffers[1].name, "")) then

  local buffers = vim.fn.getbufinfo({ bufloaded = true, buflisted = true })
  if #buffers == 0 or (#buffers == 1 and buffers[1].name == "") then
    vim.cmd("e " .. note_path .. name)
  else
    vim.cmd("vs " .. note_path .. name)
  end
end

vim.keymap.set("n", "<leader>no", function() open_note("personal/personal.md") end, { desc = "open personal note" })
vim.keymap.set("n", "<leader>nw", function() open_note("work/work.md") end, { desc = "open work note" })

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
