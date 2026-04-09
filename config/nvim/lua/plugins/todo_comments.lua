return {
	'folke/todo-comments.nvim',
	event = 'VeryLazy',
	dependencies = { 'nvim-lua/plenary.nvim' },
	opts = {
		signs = false,
	},
	keys = {
		{ '<leader>st', '<cmd>TodoQuickFix<CR>', desc = 'Search TODOs' },
		{ ']t', function() require('todo-comments').jump_next() end, desc = 'Next TODO' },
		{ '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous TODO' },
	},
}
