-- telescope.lua
local map = vim.keymap.set

require('telescope').setup {
	defaults = {
		prompt_prefix = "> ",
		selection_caret = "> ",
		entry_prefix = "  ",
		initial_mode = "insert",
		layout_strategy = "bottom_pane",
		layout_config = {
			horizontal = { mirror = false },
			vertical = { mirror = false },
		},
		winblend = 0,
		border = false,
		borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
		color_devicons = false,
	},
	pickers = {
		find_files = { no_ignore = true },
	},
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('egrepify')

map("n", "<C-;>", "<cmd>Telescope neoclip<cr>")
map("n", "<C-e>", "<cmd>Telescope egrepify<cr>")
map("n", "<C-p>", "<cmd>Telescope find_files<cr>")
map("n", "<C-_>", "<cmd>Telescope live_grep<cr>")
map("n", "<C-y>", "<cmd>Telescope buffers<cr>")
