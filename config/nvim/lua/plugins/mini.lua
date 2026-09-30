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
		require("mini.tabline").setup({
			show_icons = false,
			format = function(buf_id, label)
				local modified = vim.bo[buf_id].modified and " ●" or ""
				return string.format("  %s%s  ", label, modified)
			end,
		})

		-- hide the empty startup buffer (`nvim .` leaves one behind) so it doesn't show as a "*" tab
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local empty = vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
			if vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) == "" and not vim.bo[buf].modified and empty then
				vim.bo[buf].buflisted = false
			end
		end

		-- start the tabs after the snacks explorer sidebar instead of over it
		local make_tabline = MiniTabline.make_tabline_string
		MiniTabline.make_tabline_string = function()
			local explorer = Snacks.picker.get({ source = "explorer" })[1]
			local root = explorer and not explorer.layout.closed and explorer.layout.root.win
			if not (root and vim.api.nvim_win_is_valid(root)) then
				return make_tabline()
			end
			local width = vim.api.nvim_win_get_width(root) + 1
			local label = "Explorer"
			local left = math.floor((width - #label) / 2)
			local pad = string.rep(" ", left) .. label .. string.rep(" ", width - left - #label)
			return "%#SnacksPickerList#" .. pad .. make_tabline()
		end
	end,
}
