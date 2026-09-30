return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	keys = {
		{ "<leader>gh", "<cmd>CodeDiff history %<cr>", desc = "Git history (current file)" },
		{ "<leader>gH", "<cmd>CodeDiff history %:p:h<cr>", desc = "Git history (current folder)" },
		{
			"<leader>g?",
			function()
				local folder = vim.fn.input("Folder path for history: ", "./", "dir")
				if folder == nil or folder == "" then
					return
				end
				vim.cmd("CodeDiff history " .. vim.fn.fnameescape(folder))
			end,
			desc = "Git history (pick folder)",
		},
	},
	opts = {},
}
