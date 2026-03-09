-- neogit.lua
require("neogit").setup({
  kind = "split_below_all",
  height = 0.4,
  integrations = {
    diffview = true,
  },
})

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
