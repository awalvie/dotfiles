-- Lean 4: LSP, infoview (proof goals) and unicode input (\and → ∧).
-- The `lean`/`lake` binaries come from each project's flake via direnv, not Mason.
return {
	"Julian/lean.nvim",
	event = { "BufReadPre *.lean", "BufNewFile *.lean" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		mappings = true,
	},
}
