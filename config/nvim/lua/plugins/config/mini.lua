-- lua/plugins/mini.lua
-- Load this file with require("plugins.mini")

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.trailspace").setup()
require("mini.indentscope").setup()
require("mini.icons").setup({
	mock_nvim_web_devicons = true,
})
