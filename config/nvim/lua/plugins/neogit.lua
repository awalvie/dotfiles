return {
	"NeogitOrg/neogit",
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
		{ "<leader>gl", "<cmd>NeogitLog %<cr>", desc = "Git log (current file)" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("neogit").setup({
			kind = "tab",
			integrations = {
				-- codediff >= 2.67.2 crashes neogit's diff views; turn back on when
				-- https://github.com/NeogitOrg/neogit/issues/2008 is fixed. Use :CodeDiff directly.
				codediff = false,
				snacks = true,
			},
		})
	end,
}
