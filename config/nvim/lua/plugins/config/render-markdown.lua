-- Setup render-markdown.nvim
require('render-markdown').setup({
	overrides = {
		buflisted = {},
		buftype = {
			nofile = {
				render_modes = true,
				padding = { highlight = 'NormalFloat' },
				sign = { enabled = false },
			},
		},
		filetype = {},
	},
})

-- Then override the LSP hover handler.
vim.lsp.handlers.textDocument_hover = require('render-markdown').hover
