return {
	"kdheepak/lazygit.nvim",
	cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
	init = function()
		vim.g.lazygit_floating_window_winblend = 0
		vim.g.lazygit_floating_window_scaling_factor = 0.9
		vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
		vim.g.lazygit_floating_window_use_plenary = 0
		vim.g.lazygit_use_neovim_remote = 0
		vim.g.lazygit_use_custom_config_file_path = 0
		vim.g.lazygit_config_file_path = ""
		vim.g.lazygit_on_exit_callback = nil
	end,
}
