-- bufferline.lua
local bufferline = require('bufferline')
bufferline.setup {
	options = {
		always_show_bufferline = true,
		style_preset = bufferline.style_preset.minimal,
		color_icons = false,
		show_buffer_icons = false,
		offsets = {
			{
				filetype = "neo-tree",
				text = "Neotree",
				text_align = "center",
				separator = true,
			}
		}
	}
}
