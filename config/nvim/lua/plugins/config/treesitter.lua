-- Install parsers (no-op if already installed)
require('nvim-treesitter').install({
    'go', 'python', 'yaml', 'lua', 'hcl', 'rust', 'vim', 'vimdoc',
    'latex', 'markdown', 'markdown_inline', 'bash',
})
