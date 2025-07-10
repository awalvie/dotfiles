-- conform.lua
require("conform").setup({
	formatters_by_ft = {
		python = { "isort", "ruff_format" },
		yaml = { "prettierd" }
	},
	format_on_save = {
		lsp_fallback = true,
	},
	notify_on_error = false,
})
