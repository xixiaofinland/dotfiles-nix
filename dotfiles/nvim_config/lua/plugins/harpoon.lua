return {
  'ThePrimeagen/harpoon',
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local name = "[H] "
    local harpoon = require("harpoon")
    harpoon:setup()

    harpoon:extend({
      UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-e>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })
      end,
    })

    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = name .. "add" })
    vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = name .. "list" })

    vim.keymap.set("n", "<C-p>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-d>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-t>", function() harpoon:list():select(4) end)
    vim.keymap.set("n", "<C-g>", function() harpoon:list():select(5) end)
    vim.keymap.set("n", "<C-m>", function() harpoon:list():select(6) end)
  end
}
