return {
	'NeogitOrg/neogit',
	cmd = 'Neogit',
	keys = {
		{ '<leader>gg', '<cmd>Neogit<cr>',      desc = 'Neogit' },
		{ '<leader>gl', '<cmd>NeogitLog %<cr>', desc = 'Git log (current file)' },
	},
	dependencies = {
		'nvim-lua/plenary.nvim',
		'sindrets/diffview.nvim',
	},
	config = function()
		require("neogit").setup({
			kind = "tab",
			integrations = {
				diffview = true,
				mini_picker = true,
				snacks = false,
			},
		})
	end,
}
