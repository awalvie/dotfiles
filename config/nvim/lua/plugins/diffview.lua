return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview history (current file)" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory -- %:p:h<cr>", desc = "Diffview history (current folder)" },
		{
			"<leader>g?",
			function()
				local folder = vim.fn.input("Folder path for history: ", "./", "dir")
				if folder == nil or folder == "" then
					return
				end
				vim.cmd("DiffviewFileHistory -- " .. vim.fn.fnameescape(folder))
			end,
			desc = "Diffview history (pick folder)",
		},
	},
	config = function()
		require("diffview").setup({
			keymaps = {
				view = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
				file_panel = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
				file_history_panel = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
			},
		})
	end,
}
