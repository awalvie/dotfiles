require('utils')

local o = vim.opt
local g = vim.g
local cmd = vim.cmd

-- neotree
nmap('<leader>n', '<cmd>Neotree toggle reveal<cr>')

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  window = {
    width = 30,
    position = "left",
  },
  filesystem = {
    hijack_netrw_behavior = "open_current",
  },
  source_selector = {
    winbar = true,
    content_layout = "center",
    sources = {
      {
        source = "filesystem",
        display_name = " 󰉓  ",
      },
      {
        source = "buffers",
        display_name = " 󰈚  ",
      },
      {
        source = "git_status",
        display_name = " 󰊢  ",
      },
      {
        source = "document_symbols",
        display_name = " 󰌗  ",
      },
    },
  }
})

-- nerdcommenter
require('Comment').setup()

-- telescope
require('telescope').setup {
  defaults = {
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    layout_strategy = "bottom_pane",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    winblend = 0,
    border = false,
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = false,
  },
  pickers = {
    find_files = {
      no_ignore = true,
    },
  },
}

-- Additional telescope extensions
require('telescope').load_extension('fzf')
require('telescope').load_extension('egrepify')

nmap("<C-;>", "<cmd>Telescope neoclip<cr>")
nmap("<C-e>", "<cmd>Telescope egrepify<cr>")
nmap("<C-p>", "<cmd>Telescope find_files<cr>")
nmap("<C-_>", "<cmd>Telescope live_grep<cr>")
nmap("<C-y>", "<cmd>Telescope buffers<cr>")

-- Treesitter config
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "python", "yaml", "lua", "hcl", "rust", "vim", "vimdoc", "latex", "markdown", "markdown_inline", "bash" },

  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}

-- module configuration
require 'treesitter-context'.setup {
  enable = true,
  throttle = true,
  max_lines = 2,
}

-- Lualine config
require('lualine').setup({
  options = {
    icons_enabled = 'false',
    globalstatus = true,
  }
})

-- Bufferline config
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
  preselect = cmp.PreselectMode.None,
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
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
    { name = 'nvim_lsp_signature_help' }
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

-- lsp configuration
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

local servers = { 'clangd', 'gopls', 'yamlls', 'terraform_lsp', 'rust_analyzer', 'lua_ls', 'html', 'pylsp', 'bashls',
  'ansiblels', 'pyright' }

local capabilities = require('cmp_nvim_lsp').default_capabilities()

for _, lsp in ipairs(servers) do
  vim.lsp.enable(lsp)
end

-- copilot
cmd([[
  imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
]])
g.copilot_no_tab_map = true


-- mason
require("mason").setup()

-- Configure intdent-blankline
require("ibl").setup()

-- Configure conform
require("conform").setup({
  formatters_by_ft = {
    python = { "isort", "ruff_format" },
    yaml = { "prettierd" }
  },
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_fallback = true,
  },
  notify_on_error = false,
})

-- Neogit config
require('neogit').setup {
  kind = "split",
}

nmap('<leader>gg', '<cmd>Neogit<cr>')

-- Python config
g.python3_host_prog = '/home/hyperion/.pyenv/versions/vim/bin/python3'
g.python_host_prog = '/home/hyperion/.pyenv/versions/vim/bin/python'

-- Diffview config
require('diffview').setup({
  enhanced_diff_hl = true,
})
nmap('<leader>dv', '<cmd>DiffviewOpen<cr>')
nmap('<leader>dc', '<cmd>DiffviewClose<cr>')
nmap('<leader>dr', '<cmd>DiffviewRefresh<cr>')
nmap('<leader>df', '<cmd>DiffviewFileHistory<cr>')
