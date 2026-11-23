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
		-- statusline: MODE | branch, diff, diagnostics | file ...... filetype, search | line:col
		local sl = require("mini.statusline")
		sl.setup({
			use_icons = false,
			content = {
				active = function()
					local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
					local git = sl.section_git({ trunc_width = 40, icon = "" })
					local diff = sl.section_diff({ trunc_width = 75, icon = "" })
					local diag = sl.section_diagnostics({
						trunc_width = 75,
						icon = "",
						signs = { ERROR = "E", WARN = "W", INFO = "I", HINT = "H" },
					})
					local search = sl.section_searchcount({ trunc_width = 75 })
					return sl.combine_groups({
						{ hl = mode_hl, strings = { mode:upper() } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diag } },
						"%<",
						{ hl = "MiniStatuslineFilename", strings = { "%f%m" } },
						"%=",
						{ hl = "MiniStatuslineFileinfo", strings = { vim.bo.filetype, search } },
						{ hl = mode_hl, strings = { "%l:%v" } },
					})
				end,
			},
		})

		-- colour TODO-style words in comments
		local word = function(w, group)
			return { pattern = "%f[%w]()" .. w .. "()%f[%W]", group = group }
		end
		require("mini.hipatterns").setup({
			highlighters = {
				fixme = word("FIXME", "MiniHipatternsFixme"),
				bug = word("BUG", "MiniHipatternsFixme"),
				hack = word("HACK", "MiniHipatternsHack"),
				warn = word("WARN", "MiniHipatternsHack"),
				perf = word("PERF", "MiniHipatternsHack"),
				todo = word("TODO", "MiniHipatternsTodo"),
				note = word("NOTE", "MiniHipatternsNote"),
			},
		})

		-- code overview on the right, with search, diagnostic and git marks.
		-- Open at start; toggle with ,mm
		local map = require("mini.map")
		map.setup({
			integrations = {
				map.gen_integration.builtin_search(),
				map.gen_integration.diagnostic(),
				map.gen_integration.gitsigns(),
			},
			-- braille dots (2x4 per cell) in place of solid blocks
			symbols = { encode = map.gen_encode_symbols.dot("4x2") },
			window = { width = 12, show_integration_count = false },
		})
		vim.keymap.set("n", "<leader>mm", MiniMap.toggle, { desc = "Toggle code map" })
		MiniMap.open()

		-- key hints: after a prefix key, a window lists the keys that can follow
		local clue = require("mini.clue")
		clue.setup({
			triggers = {
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },
				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },
				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
				{ mode = "n", keys = "<C-w>" },
				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "n", keys = '"' },
				{ mode = "x", keys = '"' },
				{ mode = "i", keys = "<C-r>" },
				{ mode = "c", keys = "<C-r>" },
			},
			clues = {
				clue.gen_clues.builtin_completion(),
				clue.gen_clues.g(),
				clue.gen_clues.marks(),
				clue.gen_clues.registers(),
				clue.gen_clues.windows(),
				clue.gen_clues.z(),
				{ mode = "n", keys = "<Leader>b", desc = "+buffer" },
				{ mode = "n", keys = "<Leader>c", desc = "+code" },
				{ mode = "n", keys = "<Leader>d", desc = "+diff" },
				{ mode = "n", keys = "<Leader>g", desc = "+git" },
				{ mode = "n", keys = "<Leader>m", desc = "+map" },
				{ mode = "n", keys = "<Leader>r", desc = "+restart" },
				{ mode = "n", keys = "<Leader>s", desc = "+show" },
				{ mode = "n", keys = "<Leader>u", desc = "+undo" },
				{ mode = "n", keys = "<Leader>w", desc = "+window" },
				{ mode = "n", keys = "<Leader>x", desc = "+lists" },
			},
			window = { delay = 200, config = { width = "auto", border = "rounded" } },
		})
		-- mini.clue skips unlisted buffers; turn it on in the snacks explorer too
		-- (the explorer may already be open when this runs, after `nvim .`)
		local function explorer_triggers(buf)
			if vim.bo[buf].filetype == "snacks_picker_list" then
				MiniClue.ensure_buf_triggers(buf)
			end
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "snacks_picker_list",
			callback = function(ev)
				explorer_triggers(ev.buf)
			end,
		})
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			explorer_triggers(buf)
		end
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
