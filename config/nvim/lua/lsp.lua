local map = vim.keymap.set
local hover_opts = {
	border = "rounded",
}

-- Enable the servers; their configs come from nvim-lspconfig's lsp/<name>.lua files
vim.lsp.enable({
	"ty",
	"clangd",
	"gopls",
	"yamlls",
	"terraformls",
	"rust_analyzer",
	"lua_ls",
	"html",
	"bashls",
	"ansiblels",
})

-- list results in snacks pickers instead of the quickfix window
map("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })
map("n", "gD", function()
	Snacks.picker.lsp_declarations()
end, { desc = "Goto Declaration" })
map("n", "grr", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })
map("n", "gri", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
map("n", "grt", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Goto Type Definition" })
map("n", "K", function()
	vim.lsp.buf.hover(hover_opts)
end, { silent = true })
map("n", "<leader>wd", "<cmd>lua vim.lsp.buf.workspace_diagnostics()<CR>")
