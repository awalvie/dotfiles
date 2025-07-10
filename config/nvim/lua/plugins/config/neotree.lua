-- neotree.lua
local map = vim.keymap.set

map('n', '<leader>n', '<cmd>Neotree toggle reveal<cr>')

require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	window = {
		width = 30,
		position = "left",
	},
	filesystem = {
		hijack_netrw_behavior = "open_current",
	},
	source_selector = {
		winbar = true,
		content_layout = "center",
		sources = {
			{ source = "filesystem", display_name = " 󰉓  " },
			{ source = "buffers", display_name = " 󰈚  " },
			{ source = "git_status", display_name = " 󰊢  " },
			{ source = "document_symbols", display_name = " 󰌗  " },
		},
	}
})
