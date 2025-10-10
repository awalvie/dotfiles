-- lsp.lua
local map = vim.keymap.set
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure servers using vim.lsp.config (the official way)
vim.lsp.config.pylsp = {
	cmd = { 'pylsp' },
	filetypes = { 'python' },
	root_markers = { 'pyproject.toml', 'setup.py', '.git' },
	capabilities = capabilities,
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { 'E501' }, -- Ignore line length errors
				}
			}
		}
	}
}

vim.lsp.config.clangd = {
	cmd = { 'clangd' },
	filetypes = { 'c', 'cpp' },
	root_markers = { 'compile_commands.json', '.clangd', '.git' },
	capabilities = capabilities,
}

vim.lsp.config.gopls = {
	cmd = { 'gopls' },
	filetypes = { 'go', 'gomod' },
	root_markers = { 'go.mod', '.git' },
	capabilities = capabilities,
}

vim.lsp.config.yamlls = {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml', 'yml' },
	root_markers = { '.git' },
	capabilities = capabilities,
}

vim.lsp.config.terraform_lsp = {
	cmd = { 'terraform-lsp' },
	filetypes = { 'terraform' },
	root_markers = { '.terraform', '.git' },
	capabilities = capabilities,
}

vim.lsp.config.rust_analyzer = {
	cmd = { 'rust-analyzer' },
	filetypes = { 'rust' },
	root_markers = { 'Cargo.toml', '.git' },
	capabilities = capabilities,
}

vim.lsp.config.lua_ls = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
	capabilities = capabilities,
}

vim.lsp.config.html = {
	cmd = { 'vscode-html-language-server', '--stdio' },
	filetypes = { 'html' },
	root_markers = { '.git' },
	capabilities = capabilities,
}

vim.lsp.config.bashls = {
	cmd = { 'bash-language-server', 'start' },
	filetypes = { 'bash', 'sh' },
	root_markers = { '.git' },
	capabilities = capabilities,
}

vim.lsp.config.ansiblels = {
	cmd = { 'ansible-language-server', '--stdio' },
	filetypes = { 'ansible' },
	root_markers = { 'ansible.cfg', '.git' },
	capabilities = capabilities,
}

-- Enable the configured servers
vim.lsp.enable({ 'pylsp', 'clangd', 'gopls', 'yamlls', 'terraform_lsp', 'rust_analyzer', 'lua_ls', 'html', 'bashls', 'ansiblels' })

map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', 'K', "<cmd>Lspsaga hover_doc<CR>", { silent = true })
map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')


