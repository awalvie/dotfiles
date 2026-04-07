return {
	'nvim-neo-tree/neo-tree.nvim',
	branch = 'v3.x',
	lazy = false,
	init = function()
		-- Required for hijack_netrw_behavior to take over directory opens (e.g. `nvim .`).
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
	},
	config = function()
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
	end,
}
