---------------------------------------
-- bootstrap and install paq
  local PKGS = {
    "savq/paq-nvim";

	---------------------------------------
	-- Plugin list --

	-- surround things with different things
	'tpope/vim-surround';
	-- File naivator
	'scrooloose/nerdtree';
	-- Main theme for vim
	'morhetz/gruvbox';
	-- Statusline theme for gruvbos
	'vim-airline/vim-airline';
	'vim-airline/vim-airline-themes';
	-- Distraction free mode when writing prose
	'junegunn/goyo.vim';
	-- Plugin for auto-completing closing brackets
	'jiangmiao/auto-pairs';
	-- Plugin for quickly commenting out code
	'preservim/nerdcommenter';
	-- Auto Code Formatter
	'chiel92/vim-autoformat';
	-- rip grep, yeah, I'm going into the corner
	'jremmen/vim-ripgrep';
	-- hahaha, I laugh at you emacs peasents
	'jreybert/vimagit';
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

	-- Language Plugins
	-- markdown formatting
	'godlygeek/tabular';
	'plasticboy/vim-markdown';
	'vim-pandoc/vim-pandoc-syntax';
	-- HTML autoclose tag
	'alvan/vim-closetag';
	-- Formatter for C code
	'rhysd/vim-clang-format';
	-- golang plugin for vim
	'fatih/vim-go';
  }

  local function clone_paq()
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
    if vim.fn.empty(vim.fn.glob(path)) > 0 then
      vim.fn.system {
        'git',
        'clone',
        '--depth=1',
        'https://github.com/savq/paq-nvim.git',
        path
      }
    end
  end
  
  local function bootstrap_paq()
    clone_paq()
    -- Load Paq
    vim.cmd('packadd paq-nvim')
    local paq = require('paq')
    -- Exit nvim after installing plugins
    vim.cmd('autocmd User PaqDoneInstall quit')
    -- Read and install packages
    paq(PKGS)
    paq.install()
  end

  return { bootstrap_paq = bootstrap_paq }