-- snacks.lua
local map = vim.keymap.set

require("snacks").setup({
	picker = {
		enabled = true,
		layout = {
			preset = "telescope",
			layout = {
				position = "bottom",
				height = 0.45,
				backdrop = false,
			},
		},
	},
})

map("n", "<C-;>", function() Snacks.picker.registers() end, { desc = "Registers" })
map("n", "<C-p>", function() Snacks.picker.files({ ignored = true, hidden = true }) end, { desc = "Find Files" })
map("n", "<C-_>", function() Snacks.picker.grep() end, { desc = "Live Grep" })
map("n", "<C-y>", function() Snacks.picker.buffers() end, { desc = "Buffers" })
