-- lua/plugins/mini.lua
-- Load this file with require("plugins.mini")

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.comment").setup()
require("mini.trailspace").setup()
require("mini.indentscope").setup()
require("mini.jump").setup()
require("mini.icons").setup()

-- Disable mini.jump in neogit buffers so its keybinds don't interfere
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NeogitStatus", "NeogitLog", "NeogitCommitView", "NeogitPopup", "Neogit*" },
  callback = function()
    vim.b.minijump_disable = true
  end,
})
