return {
	'nvim-mini/mini.nvim',
	event = 'VeryLazy',
	version = '*',
	config = function()
		require("mini.pairs").setup()
		require("mini.surround").setup()
		require("mini.trailspace").setup()
		require("mini.icons").setup({
			mock_nvim_web_devicons = true,
		})
	end,
}
