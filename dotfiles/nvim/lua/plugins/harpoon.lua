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
        vim.keymap.set("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })
      end,
    })

    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = name .. "add" })
    vim.keymap.set("n", "<leader>ht", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = name .. "list" })

    for index = 1, 6 do
      vim.keymap.set("n", "<leader>h" .. index, function()
        harpoon:list():select(index)
      end, { desc = name .. "move to #" .. index })
    end
  end
}
