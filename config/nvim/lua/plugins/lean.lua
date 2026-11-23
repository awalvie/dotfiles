-- Lean 4: LSP, infoview (proof goals) and unicode input (\and → ∧).
-- The `lean`/`lake` binaries come from each project's flake via direnv, not Mason.
-- lean.nvim reads vim.g.lean_config and has no setup(), so configure it in
-- `init` (lazy's `opts` would call the missing setup()).
return {
	"Julian/lean.nvim",
	event = { "BufReadPre *.lean", "BufNewFile *.lean" },
	dependencies = { "nvim-lua/plenary.nvim" },
	init = function()
		vim.g.lean_config = {
			mappings = true,
			-- plain text in place of the default emoji
			goal_markers = { unsolved = " ⚒ ", accomplished = "✓" },
			infoview = { messages = { goals = { accomplished = "Goals accomplished" } } },
		}
	end,
}
