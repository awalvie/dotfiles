local map = vim.keymap.set
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local hover_opts = {
	border = "rounded",
}

-- Configure servers using vim.lsp.config (the official way)
vim.lsp.config.ty = {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.clangd = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp" },
	root_markers = { "compile_commands.json", ".clangd", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod" },
	root_markers = { "go.mod", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.yamlls = {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yml" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

vim.lsp.config.terraformls = {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform" },
	root_markers = { ".terraform", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.html = {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

vim.lsp.config.bashls = {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

vim.lsp.config.ansiblels = {
	cmd = { "ansible-language-server", "--stdio" },
	filetypes = { "ansible" },
	root_markers = { "ansible.cfg", ".git" },
	capabilities = capabilities,
}

-- Enable the configured servers
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
