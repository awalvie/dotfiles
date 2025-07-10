-- gitsigns.lua
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

		map("n", "<leader>gn", gs.next_hunk, "Next Hunk")
		map("n", "<leader>gp", gs.prev_hunk, "Prev Hunk")
		map({ "n", "v" }, "<leader>ga", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
		map({ "n", "v" }, "<leader>gu", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
		map("n", "<leader>gA", gs.stage_buffer, "Stage Buffer")
		map("n", "<leader>gU", gs.undo_stage_hunk, "Undo Stage Hunk")
		map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
		map("n", "<leader>gd", gs.preview_hunk_inline, "Preview Hunk Inline")
		map("n", "<leader>gbl", function() gs.blame_line({ full = true }) end, "Blame Line")
		map("n", "<leader>gD", gs.diffthis, "Diff This")
	end,
})
