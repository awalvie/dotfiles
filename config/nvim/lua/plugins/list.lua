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
-- vimwiki
'vimwiki/vimwiki';


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

---------------------------------------
-- Source plugin specific settings

require('plugins.config')
