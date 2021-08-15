require('lspconfig').gopls.setup {
	on_attach=require'completion'.on_attach
}
