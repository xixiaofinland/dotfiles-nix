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
vim.keymap.set("n", "<leader>no", ":vs " .. note_path .. "personal.md<CR>", { desc = "open personal note" })
vim.keymap.set("n", "<leader>nw", ":vs " .. note_path .. "work.md<CR>", { desc = "open work note" })

local push_cmd = "cd " .. note_path .. "; git commit -am \"+\"; git push;"
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
