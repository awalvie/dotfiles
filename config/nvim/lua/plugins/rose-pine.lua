return {
	"rose-pine/neovim",
	name = "rose-pine",
	lazy = false,
	priority = 1000,
	config = function()
		require("rose-pine").setup({
			variant = "main",
			highlight_groups = {
				-- rose-pine has no mini.tabline theme, so the tabs fall back to plain TabLine
				MiniTablineCurrent = { fg = "text", bg = "overlay", bold = true },
				MiniTablineVisible = { fg = "subtle", bg = "base" },
				MiniTablineHidden = { fg = "muted", bg = "base" },
				MiniTablineModifiedCurrent = { fg = "gold", bg = "overlay", bold = true },
				MiniTablineModifiedVisible = { fg = "gold", bg = "base" },
				MiniTablineModifiedHidden = { fg = "gold", bg = "base" },
				MiniTablineFill = { bg = "base" },
				MiniTablineTrunc = { fg = "pine", bg = "base" },
				MiniTablineTabpagesection = { fg = "base", bg = "foam", bold = true },

				-- brighter matches and borders that stay visible against the base background
				BlinkCmpLabelMatch = { fg = "foam", bold = true },
				BlinkCmpMenuBorder = { fg = "highlight_high" },
				BlinkCmpDocBorder = { fg = "highlight_high" },
				BlinkCmpSignatureHelpBorder = { fg = "highlight_high" },
				BlinkCmpLabelDescription = { fg = "muted" },
			},
		})
		vim.cmd.colorscheme("rose-pine")
	end,
}
