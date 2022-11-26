---------------------------------------
-- Plugin list

require 'paq' {

  -- Let Paq manage itself
  "savq/paq-nvim";
  -- surround things with different things
  'tpope/vim-surround';
  -- File naivator
  'scrooloose/nerdtree';
  -- Main theme for vim
  'morhetz/gruvbox';
  -- Statusline theme for gruvbos
  'nvim-lualine/lualine.nvim';
  { 'kyazdani42/nvim-web-devicons', opt = true };
  -- Plugin for auto-completing closing brackets
  'jiangmiao/auto-pairs';
  -- Plugin for quickly commenting out code
  'preservim/nerdcommenter';
  -- Auto Code Formatter
  'chiel92/vim-autoformat';
  -- rip grep, yeah, I'm going into the corner
  'jremmen/vim-ripgrep';
  -- git gutter, finally yes, I need to clean up this config sometime
  'airblade/vim-gitgutter';
  -- sit on that tree
  'nvim-treesitter/nvim-treesitter';
  'nvim-treesitter/playground';
  -- telescope
  'nvim-telescope/telescope.nvim';
  'nvim-lua/plenary.nvim';
  -- lspconfig
  'neovim/nvim-lspconfig';
  -- coq
  { 'ms-jpq/coq_nvim', run = 'python3 -m coq deps' };
  'ms-jpq/coq.artifacts';
  -- yaml folding
   'pedrohdz/vim-yaml-folds';

  -- Language Plugins
  'fatih/vim-go';
  'rust-lang/rust.vim';
}

---------------------------------------
-- Source plugin specific settings

require('plugins.config')
