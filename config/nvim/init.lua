-- This is the main configuration file for Neovim.

-- Set leader key early
vim.g.mapleader = ","

-- Enable the experimental Neovim 0.12 message/cmdline UI when available.
do
	local ok, ui2 = pcall(require, "vim._core.ui2")
	if ok then
		ui2.enable({
			enable = true,
			msg = {
				targets = "cmd",
				msg = {
					timeout = 4000,
					height = 0.5,
				},
				pager = {
					height = 1.0,
				},
			},
		})
	end
end

-- Load config + plugins
require("options")
require("keymaps")
require("autocmds")
require("filetype")
require("lazy_setup")
