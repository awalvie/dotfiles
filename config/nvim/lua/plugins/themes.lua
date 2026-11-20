-- The other colour schemes `theme set` can pick (config/themes/*/*/nvim).
-- They load before rose-pine (higher priority), whose config applies the
-- scheme the current theme names.

-- the applied variant's mode, for schemes that follow 'background'
local function theme_mode()
	local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
	local f = io.open(state .. "/theme/current/mode")
	if not f then
		return "dark"
	end
	local mode = f:read("*l")
	f:close()
	return mode == "light" and "light" or "dark"
end

return {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1001,
		config = function()
			-- these schemes have one name for both variants and follow
			-- 'background', so set it from the applied variant first
			vim.api.nvim_create_autocmd("ColorSchemePre", {
				pattern = { "gruvbox", "everforest", "solarized", "kanagawa-*" },
				callback = function()
					vim.o.background = theme_mode()
				end,
			})
		end,
	},
	{
		"neanias/everforest-nvim",
		main = "everforest",
		lazy = false,
		priority = 1001,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1001,
	},
	{
		"maxmx03/solarized.nvim",
		lazy = false,
		priority = 1001,
	},
	{
		"kepano/flexoki-neovim",
		name = "flexoki",
		lazy = false,
		priority = 1001,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1001,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1001,
	},
}
