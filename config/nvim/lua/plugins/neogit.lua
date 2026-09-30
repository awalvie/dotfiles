return {
	"NeogitOrg/neogit",
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
		{ "<leader>gl", "<cmd>NeogitLog %<cr>", desc = "Git log (current file)" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"esmuellert/codediff.nvim",
	},
	config = function()
		require("neogit").setup({
			kind = "tab",
			diff_viewer = "codediff",
			integrations = {
				codediff = true,
				snacks = true,
			},
		})
	end,
}
