return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		local map = vim.keymap.set

		require("snacks").setup({
			dashboard = { enabled = true },
			notifier = { enabled = true },
			bigfile = { enabled = true },
			gh = { enabled = true },
			indent = {
				enabled = true,
				indent = {
					enabled = true,
					char = "│",
				},
				scope = {
					enabled = true,
					char = "│",
				},
			},
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
					gh_issue = { layout = { preset = "default" } },
					gh_pr = { layout = { preset = "default" } },
				},
				layout = {
					preset = "telescope",
					layout = {
						position = "bottom",
						height = 0.45,
						backdrop = false,
					},
				},
			},
		})

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
