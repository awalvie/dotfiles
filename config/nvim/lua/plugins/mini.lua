return {
	"nvim-mini/mini.nvim",
	event = "VeryLazy",
	version = "*",
	config = function()
		require("mini.pairs").setup()
		require("mini.surround").setup({
			mappings = {
				add = "gza",
				delete = "gzd",
				find = "gzf",
				find_left = "gzF",
				highlight = "gzh",
				replace = "gzr",
				update_n_lines = "gzn",

				suffix_last = "l",
				suffix_next = "n",
			},
		})
		require("mini.ai").setup()
		require("mini.trailspace").setup()
		require("mini.pick").setup()
		require("mini.tabline").setup({ show_icons = false })

		-- start the tabs after the snacks explorer sidebar instead of over it
		local make_tabline = MiniTabline.make_tabline_string
		MiniTabline.make_tabline_string = function()
			local explorer = Snacks.picker.get({ source = "explorer" })[1]
			local root = explorer and not explorer.layout.closed and explorer.layout.root.win
			if not (root and vim.api.nvim_win_is_valid(root)) then
				return make_tabline()
			end
			return string.rep(" ", vim.api.nvim_win_get_width(root) + 1) .. make_tabline()
		end
	end,
}
