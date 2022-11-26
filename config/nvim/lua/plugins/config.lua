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
g.gitgutter_override_sign_column_highlight = 1

cmd[[au VimEnter * highlight SignColumn guibg=bg]]
cmd[[au VimEnter * highlight SignColumn ctermbg=bg]]

-- Jump between hunks
nmap('<Leader>gn', '<cmd>GitGutterNextHunk<cr>')
nmap('<Leader>gp', '<cmd>GitGutterPrevHunk<cr>')

-- Hunk-add and hunk-revert for chunk staging
nmap('<Leader>ga', '<cmd>GitGutterStageHunk<cr>')
nmap('<Leader>gu', '<cmd>GitGutterUndoHunk<cr>')
nmap('<leader>gd', '<cmd>GitGutterPreviewHunk<cr>')

-- Nerd tree
nmap('<leader>n','<cmd>NERDTreeToggle<cr>')
nmap('<leader>m','<cmd>NERDTreeFind<cr>')

-- close vim if the only window left open is a NERDTree
cmd([[
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
]])

-- nerdcommenter
g.NERDSpaceDelims = 1

-- telescope
require('telescope').setup{
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
    file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    path_display = {},
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
  }
}

nmap("<C-p>", "<cmd>Telescope find_files<cr>")
nmap("<C-_>", "<cmd>Telescope live_grep<cr>")
nmap("<C-y>", "<cmd>Telescope buffers<cr>")

-- lspconfig
local lspconfig = require('lspconfig')

nmap('gd','<cmd>lua vim.lsp.buf.definition()<CR>')
nmap('gr','<cmd>lua vim.lsp.buf.references()<CR>')
nmap('gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
nmap('K','<cmd>lua vim.lsp.buf.hover()<CR>')
nmap('<space>rn','<cmd>lua vim.lsp.buf.rename()<CR>')

-- coq
g.coq_settings = {
  keymap = {
    jump_to_mark = '<nop>',
  },
  auto_start = 'shut-up',
  display = {
    icons = {
      mode = 'none'
    },
    preview = {
      border = 'solid',
    },
  },
}

-- Enable some language servers with the additional completion capabilities offered by coq_nvim
local servers = { 'clangd', 'pyright', 'gopls', 'yamlls', "terraform_lsp" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(require('coq').lsp_ensure_capabilities({
    -- on_attach = my_custom_on_attach,
  }))
end

-- Treesitter config
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "python", "yaml", "lua", "hcl" },

  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}

-- Lualine config
require('lualine').setup {
  options = {
    component_separators = { left = ' ', right = ' '},
    section_separators = { left = ' ', right = ' '},
    always_divide_middle = false,
    icons_enabled = false,
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        filetype_names = {
          nerdtree = 'explorer',
        },
      }
    }
  }
}
