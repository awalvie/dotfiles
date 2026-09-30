return {
	"gbprod/nord.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nord").setup({
			-- nord has no mini.tabline theme, so the tabs fall back to plain TabLine
			on_highlights = function(hl, c)
				local bg = c.polar_night.origin
				hl.MiniTablineCurrent = { fg = c.snow_storm.brightest, bg = c.polar_night.brighter, bold = true }
				hl.MiniTablineVisible = { fg = c.snow_storm.origin, bg = bg }
				hl.MiniTablineHidden = { fg = c.polar_night.light, bg = bg }
				hl.MiniTablineModifiedCurrent = { fg = c.aurora.yellow, bg = c.polar_night.brighter, bold = true }
				hl.MiniTablineModifiedVisible = { fg = c.aurora.yellow, bg = bg }
				hl.MiniTablineModifiedHidden = { fg = c.aurora.yellow, bg = bg }
				hl.MiniTablineFill = { bg = bg }
				hl.MiniTablineTrunc = { fg = c.frost.artic_water, bg = bg }
				hl.MiniTablineTabpagesection = { fg = bg, bg = c.frost.ice, bold = true }

				-- nord sets this from c.polar_night.ice, which doesn't exist, so matches get no color
				hl.BlinkCmpLabelMatch = { fg = c.frost.ice, bold = true }
				-- nord1 borders barely show against the nord0 background
				hl.BlinkCmpMenuBorder = { fg = c.polar_night.brightest }
				hl.BlinkCmpDocBorder = { fg = c.polar_night.brightest }
				hl.BlinkCmpSignatureHelpBorder = { fg = c.polar_night.brightest }
				hl.BlinkCmpLabelDescription = { fg = c.polar_night.light }
			end,
		})
		vim.cmd.colorscheme("nord")
	end,
}
