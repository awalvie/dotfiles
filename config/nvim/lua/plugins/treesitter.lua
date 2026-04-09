return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        -- Install parsers (no-op if already installed)
        require('nvim-treesitter').install({
            'go', 'python', 'yaml', 'lua', 'hcl', 'rust', 'vim', 'vimdoc',
            'latex', 'markdown', 'markdown_inline', 'bash',
        })

        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('NvimTreesitterStart', { clear = true }),
            callback = function(args)
                if vim.bo[args.buf].buftype ~= '' then
                    return
                end

                -- Gracefully skip filetypes without an installed parser.
                pcall(vim.treesitter.start, args.buf)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
