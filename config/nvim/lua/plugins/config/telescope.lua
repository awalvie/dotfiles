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
	extensions = {
		fzf = {
		  fuzzy = true,                    -- false will only do exact matching
		  override_generic_sorter = true,  -- override the generic sorter
		  override_file_sorter = true,     -- override the file sorter
		  case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
	   }
	 }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('egrepify')

map("n", "<C-;>", "<cmd>Telescope neoclip<cr>")
map("n", "<C-e>", "<cmd>Telescope egrepify<cr>")
map("n", "<C-p>", "<cmd>Telescope find_files<cr>")
map("n", "<C-_>", "<cmd>Telescope live_grep<cr>")
map("n", "<C-y>", "<cmd>Telescope buffers<cr>")
