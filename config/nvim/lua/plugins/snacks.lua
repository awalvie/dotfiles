return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		local map = vim.keymap.set

		require("snacks").setup({
			-- only on a bare `nvim`; snacks also opens it for `nvim <dir>` when the explorer is on
			dashboard = { enabled = vim.fn.argc(-1) == 0 },
			notifier = { enabled = true },
			bigfile = { enabled = true },
			explorer = { enabled = true },
			indent = { enabled = true },
			lazygit = { config = { gui = { nerdFontsVersion = "" } } }, -- no icons
			styles = { lazygit = { border = "rounded" } },
			picker = {
				enabled = true,
				sources = {
					files = {
						exclude = { ".venv", ".venv/**", "**/.venv/**", ".cache", ".cache/**", "**/.cache/**" },
						include = { ".github/workflows/**", "**/.github/workflows/**" },
					},
					grep = {
						exclude = { ".venv", ".venv/**", "**/.venv/**", ".cache", ".cache/**", "**/.cache/**" },
						include = { ".github/workflows/**", "**/.github/workflows/**" },
					},
					explorer = {
						-- the tabline offset in mini.lua shows the "Explorer" label instead
						title = "",
						-- let the global <C-p> file picker work from the explorer
						win = { list = { keys = { ["<c-p>"] = false } } },
					},
					gh_issue = { layout = { preset = "default" } },
					gh_pr = { layout = { preset = "default" } },
				},
				-- tweak the preset itself, so sidebar pickers (the explorer) keep their own layout
				layouts = { telescope = { layout = { position = "bottom", height = 0.45 } } },
				layout = { preset = "telescope" },
			},
		})

		map("n", "<leader>lg", function()
			Snacks.lazygit()
		end, { desc = "LazyGit" })
		map("n", "<leader>n", function()
			Snacks.explorer()
		end, { desc = "Explorer" })
		map("n", "<C-;>", function()
			Snacks.picker.registers()
		end, { desc = "Registers" })
		map("n", "<C-p>", function()
			Snacks.picker.files({ ignored = true, hidden = true })
		end, { desc = "Find Files" })
		map("n", "<C-_>", function()
			Snacks.picker.grep()
		end, { desc = "Live Grep" })
		map("n", "<C-y>", function()
			Snacks.picker.buffers()
		end, { desc = "Buffers" })
		map("n", "<leader>sk", function()
			Snacks.picker.keymaps()
		end, { desc = "Keymaps" })
		map("n", "<leader>sn", function()
			Snacks.notifier.show_history()
		end, { desc = "Notification History" })
		map("n", "<leader>gi", function()
			Snacks.picker.gh_issue()
		end, { desc = "GitHub Issues (open)" })
		map("n", "<leader>gI", function()
			Snacks.picker.gh_issue({ state = "all" })
		end, { desc = "GitHub Issues (all)" })
		map("n", "<leader>gp", function()
			Snacks.picker.gh_pr()
		end, { desc = "GitHub Pull Requests (open)" })
		map("n", "<leader>gP", function()
			Snacks.picker.gh_pr({ state = "all" })
		end, { desc = "GitHub Pull Requests (all)" })
	end,
}
