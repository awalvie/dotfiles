return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			current_line_blame = true,
			signs_staged_enable = true,
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				map("n", "]h", function()
					gs.nav_hunk("next")
				end, "Next Hunk")
				map("n", "[h", function()
					gs.nav_hunk("prev")
				end, "Prev Hunk")
				map({ "n", "v" }, "<leader>ga", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
				map({ "n", "v" }, "<leader>gu", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>gA", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
				map("n", "<leader>gd", gs.preview_hunk_inline, "Preview Hunk Inline")
				map("n", "<leader>gbl", function()
					gs.blame_line({ full = true })
				end, "Blame Line")
				map("n", "<leader>gD", gs.diffthis, "Diff This")
			end,
		})
	end,
}
