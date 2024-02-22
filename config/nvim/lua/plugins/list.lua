local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","

require("lazy").setup({
  -- automatically add brackets
  'm4xshen/autoclose.nvim',
  -- surround things with different things
  'tpope/vim-surround',
  -- File navigator
  'scrooloose/nerdtree',
  -- Main theme for vim
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({})
      vim.cmd.colorscheme("nord")
    end,
  },
  install = {
    colorscheme = { "nord" },
  },
  -- Statusline theme for gruvbox
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  { 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
  -- Comform formatting
  'stevearc/conform.nvim',
  -- Indent guide
  'lukas-reineke/indent-blankline.nvim',
  -- Plugin for quickly commenting out code
  {
    'numToStr/Comment.nvim',
    lazy = false,
  },
  -- rip grep, yeah, I'm going into the corner
  'jremmen/vim-ripgrep',
  -- git gutter, finally yes, I need to clean up this config sometime
  'airblade/vim-gitgutter',
  -- big git repos and bigger git plugins
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
    },
  },
  -- sit on that tree
  'nvim-treesitter/nvim-treesitter',
  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  -- lspconfig
  'williamboman/mason.nvim',
  'neovim/nvim-lspconfig',
  -- yaml folding
  'pedrohdz/vim-yaml-folds',
  -- completion
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',

  -- Language Plugins
  'godlygeek/tabular',
  'preservim/vim-markdown',

  -- Copilot
  'github/copilot.vim',

  -- Startup Time
  'dstein64/vim-startuptime'
})
