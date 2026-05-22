return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	init = function()
		-- Required for hijack_netrw_behavior to take over directory opens (e.g. `nvim .`).
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local map = vim.keymap.set

		map("n", "<leader>n", "<cmd>Neotree toggle reveal<cr>")

		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",
			git_status_scope_to_path = true,
			git_status_async_options = {
				batch_size = 1000,
				batch_delay = 0,
				max_lines = 2000,
			},
			window = {
				width = 30,
				position = "left",
				mappings = {
					["gd"] = function(state)
						local path = state.tree:get_node().path
						local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(path) .. " rev-parse --show-toplevel")[1]
						require("diffview")
						vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(path:sub(#git_root + 2)))
					end,
					["q"] = function()
						local listed = vim.tbl_filter(function(buf)
							return vim.bo[buf].buflisted
								and vim.api.nvim_buf_is_valid(buf)
								and vim.bo[buf].filetype ~= "neo-tree"
						end, vim.api.nvim_list_bufs())
						if #listed == 0 then
							vim.cmd("qa")
						else
							vim.cmd("Neotree close")
						end
					end,
				},
			},
			filesystem = {
				hijack_netrw_behavior = "open_current",
			},
			source_selector = {
				winbar = true,
				content_layout = "center",
				sources = {
					{ source = "filesystem", display_name = " 󰉓  " },
					{ source = "buffers", display_name = " 󰈚  " },
					{ source = "git_status", display_name = " 󰊢  " },
					{ source = "document_symbols", display_name = " 󰌗  " },
				},
			},
		})
	end,
}
