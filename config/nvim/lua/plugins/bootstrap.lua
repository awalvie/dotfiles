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
	-- markdown formatting
	'godlygeek/tabular';
	'plasticboy/vim-markdown';
	'vim-pandoc/vim-pandoc-syntax';
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
