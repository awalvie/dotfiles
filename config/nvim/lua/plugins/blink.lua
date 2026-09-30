local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	"saghen/blink.cmp",
	version = "1.*",
	opts = {
		keymap = {
			preset = "none",
			["<C-Space>"] = { "show", "fallback" },
			["<C-e>"] = { "cancel", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = {
				"select_next",
				"snippet_forward",
				function(cmp)
					if has_words_before() then
						return cmp.show()
					end
				end,
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},
		completion = {
			-- nothing is selected until <Tab>, so <CR> only accepts an item you picked
			list = { selection = { preselect = false } },
			documentation = { auto_show = true },
		},
		signature = { enabled = true },
		-- show the menu while typing `:` and `/` commands, as cmp-cmdline did
		cmdline = {
			completion = {
				menu = { auto_show = true },
				list = { selection = { preselect = false } },
			},
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				lsp = {
					-- list buffer words next to LSP items, not only when LSP has none
					fallbacks = {},
					-- drop plain-text suggestions from language servers
					transform_items = function(_, items)
						local text = require("blink.cmp.types").CompletionItemKind.Text
						return vim.tbl_filter(function(item)
							return item.kind ~= text
						end, items)
					end,
				},
			},
		},
	},
}
