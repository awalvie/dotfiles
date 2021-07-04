-- bootstrap and install paq
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/paqs/start/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({'git', 'clone',  '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
	execute 'packadd paq-nvim'
end

require 'paq-nvim' {
-- surround things with different things
'tpope/vim-surround';
-- Fuzzy file finder
'kien/ctrlp.vim';
-- File naivator
'scrooloose/nerdtree';
-- Main theme for vim
'morhetz/gruvbox';
-- Distraction free mode when writing prose
'junegunn/goyo.vim';
-- Statusline theme for gruvbos
'vim-airline/vim-airline';
'vim-airline/vim-airline-themes';
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

-- Language Plugins
-- markdown formatting
'godlygeek/tabular';
'plasticboy/vim-markdown';
'vim-pandoc/vim-pandoc-syntax';
-- HTML autoclose tag
'alvan/vim-closetag';
-- Formatter for C code
'rhysd/vim-clang-format';

}
