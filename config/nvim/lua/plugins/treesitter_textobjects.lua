return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	config = function()
		-- On the `main` branch, setup() no longer registers keymaps from the
		-- config table — they must be wired manually. Text-object *selection*
		-- (af/if/aa/ia/ac/ic) is owned by mini.ai; here we only add the
		-- *movement* maps, which mini.ai doesn't provide.
		require("nvim-treesitter-textobjects").setup({
			move = { set_jumps = true },
		})

		local move = require("nvim-treesitter-textobjects.move")
		local maps = {
			["]f"] = { move.goto_next_start, "@function.outer", "Next function start" },
			["]c"] = { move.goto_next_start, "@class.outer", "Next class start" },
			["[f"] = { move.goto_previous_start, "@function.outer", "Prev function start" },
			["[c"] = { move.goto_previous_start, "@class.outer", "Prev class start" },
		}
		for key, m in pairs(maps) do
			vim.keymap.set({ "n", "x", "o" }, key, function()
				m[1](m[2], "textobjects")
			end, { desc = m[3] })
		end
	end,
}
