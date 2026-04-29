return {
	'nvim-mini/mini.nvim',
	event = 'VeryLazy',
	version = '*',
	config = function()
		require("mini.pairs").setup()
		require("mini.surround").setup({
			mappings = {
				add = 'gza',
				delete = 'gzd',
				find = 'gzf',
				find_left = 'gzF',
				highlight = 'gzh',
				replace = 'gzr',
				update_n_lines = 'gzn',

				suffix_last = 'l',
				suffix_next = 'n',
			},
		})
		require("mini.ai").setup()
		require("mini.trailspace").setup()
		require("mini.comment").setup()
		require("mini.pick").setup()
		require("mini.icons").setup({
			mock_nvim_web_devicons = true,
		})
	end,
}
