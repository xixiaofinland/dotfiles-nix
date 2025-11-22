return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    labels = "pdlxnthkwgmj",
    modes = {
      char = {
        char_actions = function()
          return {
            [";"] = "next",
            ["F"] = "left",
            ["f"] = "right",
            ["T"] = "left",
            ["t"] = "right",
          }
        end,
        keys = { "f", "F", "t", "T", ";" },
        highlight = {
          backdrop = false,
        },
        jump_labels = false,
        multi_line = false,
      },
      search = {
        enabled = false,
      },
    },
    prompt = {
      win_config = {
        border = "none",
      },
    },
    search = {
      wrap = true,
    },
  },
  keys = {
    { "m",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    { "M",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
}
