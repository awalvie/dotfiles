require('utils')

local o = vim.opt
local g = vim.g
local cmd = vim.cmd

-- gitgutter

g.gitgutter_map_keys = 0
g.gitgutter_sign_added = '+'
g.gitgutter_sign_modified = '>'
g.gitgutter_sign_removed = '-'
g.gitgutter_sign_removed_first_line = '^'
g.gitgutter_sign_modified_removed = '<'

-- Jump between hunks
nmap('<Leader>gn', '<cmd>GitGutterNextHunk<cr>')
nmap('<Leader>gp', '<cmd>GitGutterPrevHunk<cr>')

-- Hunk-add and hunk-revert for chunk staging
nmap('<Leader>ga', '<cmd>GitGutterStageHunk<cr>')
nmap('<Leader>gu', '<cmd>GitGutterUndoHunk<cr>')
nmap('<leader>gd', '<cmd>GitGutterPreviewHunk<cr>')

-- Nerd tree
nmap('<leader>n', '<cmd>NERDTreeToggle<cr>')
nmap('<leader>m', '<cmd>NERDTreeFind<cr>')

-- close vim if the only window left open is a NERDTree
cmd([[
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
]])

-- nerdcommenter
require('Comment').setup()

-- telescope
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg', '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "bottom_pane",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    file_sorter = require 'telescope.sorters'.get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter = require 'telescope.sorters'.get_generic_fuzzy_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = false,
    use_less = true,
    path_display = {},
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    file_previewer = require 'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require 'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require 'telescope.previewers'.buffer_previewer_maker
  }
}

nmap("<C-p>", "<cmd>Telescope find_files<cr>")
nmap("<C-_>", "<cmd>Telescope live_grep<cr>")
nmap("<C-y>", "<cmd>Telescope buffers<cr>")

-- lspconfig
local lspconfig = require('lspconfig')

nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
nmap('gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
nmap('ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
nmap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
nmap('K', '<cmd>lua vim.lsp.buf.hover()<CR>')
nmap('<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
nmap('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
nmap(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')

-- Treesitter config
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "python", "yaml", "lua", "hcl", "rust", "vim", "vimdoc" },

  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}

-- Lualine config
require('lualine').setup({
  options = {
    icons_enabled = 'false',
  }
})

-- Bufferline config
local bufferline = require('bufferline')
bufferline.setup {
  options = {
    style_preset = bufferline.style_preset.minimal,
    color_icons = false,
    show_buffer_icons = false,
  }
}

-- Rust config
g.rustfmt_autosave = 1

-- Set up nvim-cmp.
local cmp = require 'cmp'
local luasnip = require 'luasnip'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

  }),
  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      entry_filter = function(entry, ctx)
        return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
      end
    },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  })
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
    { name = 'luasnip' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Enable some language servers with the additional completion capabilities offered by coq_nvim
local servers = { 'clangd', 'pylsp', 'gopls', 'yamlls', "terraform_lsp", "rust_analyzer", "lua_ls", "html", 'ruff_lsp' }
local capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(({
    capabilities = capabilities
  }))
end

g.python3_host_prog = '/home/remote/.pyenv/versions/vim/bin/python'

-- vim-go config
g.go_doc_keywordprg_enabled = 0

-- copilot
cmd([[
  imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
]])
g.copilot_no_tab_map = true


-- mason
require("mason").setup()

-- configure pylsp
require 'lspconfig'.pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        ruff = {
          enabled = true,
        },
        mypy = {
          enabled = true,
          live_mode = false,
          dmypy = True,
        },
      }
    }
  }
}

-- Configure intdent-blankline
require("ibl").setup()

-- Configure conform
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_format" },
  },
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_fallback = true,
    async = true,
  },
})

-- Automatically close brackets
require("autoclose").setup()
