return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- Install parsers (no-op if already installed)
		require("nvim-treesitter").install({
			"go",
			"python",
			"yaml",
			"lua",
			"hcl",
			"rust",
			"vim",
			"vimdoc",
			"latex",
			"markdown",
			"markdown_inline",
			"bash",
		})

		-- Enable treesitter highlighting for all buffers
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
