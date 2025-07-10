-- treesitter.lua
require('nvim-treesitter.configs').setup {
	ensure_installed = { "go", "python", "yaml", "lua", "hcl", "rust", "vim", "vimdoc", "latex", "markdown", "markdown_inline", "bash" },
	highlight = { enable = true },
	indent = { enable = true },
}

require('treesitter-context').setup {
	enable = true,
	throttle = true,
	max_lines = 2,
}
