-- diffview.lua
require("diffview").setup({
  keymaps = {
    view = {
      { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
    },
    file_panel = {
      { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
    },
    file_history_panel = {
      { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
    },
  },
})
