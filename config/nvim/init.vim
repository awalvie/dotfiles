"        _
"       (_)
" __   ___ _ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|

" Set map leader
let mapleader =","

" install vim-plug if it isn't already installed
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.config/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif


" Install the necesary plugins
call plug#begin('~/.config/nvim/plugged')

" intellisense for vim
Plug 'nvim-lua/completion-nvim'
Plug 'neovim/nvim-lspconfig'
" surround things with different things
Plug 'tpope/vim-surround'
" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" File naivator
Plug 'scrooloose/nerdtree'
" Main theme for vim
Plug 'morhetz/gruvbox'
" Distraction free mode when writing prose
Plug 'junegunn/goyo.vim'
" Statusline theme for gruvbos
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plugin for auto-completing closing brackets
Plug 'jiangmiao/auto-pairs'
" Plugin for quickly commenting out code
Plug 'preservim/nerdcommenter'
" Auto Code Formatter
Plug 'chiel92/vim-autoformat'
" hahaha, I laugh at you emacs peasents
" Plug 'jreybert/vimagit'
" git gutter, finally yes, I need to clean up this config sometime
Plug 'airblade/vim-gitgutter'
" alright, alright, fine, I'm installing it
Plug 'tpope/vim-fugitive'

" Language Plugins
" markdown formatting
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'vim-pandoc/vim-pandoc-syntax'
" HTML autoclose tag
Plug 'alvan/vim-closetag'
" Formatter for C code
Plug 'rhysd/vim-clang-format'
" golang plugin for vim
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" python pluging for vim
Plug 'vim-python/python-syntax'

call plug#end()

" source LSP configs
source ~/.config/nvim/plugin-conf/completion-config.vim
source ~/.config/nvim/plugin-conf/lsp-config.vim

" source language configs
luafile ~/.config/nvim/lua/lsp/c.lua
luafile ~/.config/nvim/lua/lsp/go.lua
luafile ~/.config/nvim/lua/lsp/python.lua

" color support for tmux
if (has("termguicolors"))
  set termguicolors
endif

" general settings
filetype plugin on
filetype indent on
syntax on
set tabstop=4
set shiftwidth=4
set autoindent
set ignorecase
set encoding=utf-8
set number relativenumber
set clipboard+=unnamedplus

" taken from drew devault's dotfiles
" https://git.sr.ht/~sircmpwn/dotfiles/tree/master/.vimrc

" Don't litter swp files everywhere
set backupdir=~/.cache
set directory=~/.cache

" Ex mode is fucking dumb
nnoremap Q <Nop>
set magic

" always have lines above and below you when scrolling
set scrolloff=3
set sidescroll=3

" Search as you type, highlight results
set incsearch
set showmatch
set hlsearch

" Preferences for various file formats
autocmd FileType c setlocal noet ts=8 sw=8 tw=80
autocmd FileType h setlocal noet ts=8 sw=8 tw=80 cc=80
autocmd FileType cpp setlocal noet ts=8 sw=8 tw=80 cc=80
autocmd FileType sh setlocal noet ts=4 sw=4
autocmd FileType go setlocal noet ts=4 sw=4
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" themeing
set background=dark
set termguicolors
let g:gruvbox_italic=1
colorscheme gruvbox
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" buffer navigation and management
set hidden
nmap <leader>T :enew<cr>
" Move to the next buffer
nmap <leader>l :bnext<CR>
" Move to the previous buffer
nmap <leader>h :bprevious<CR>
" Delete current buffer"
" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>
" Close all other buffers except the current one
command! BufOnly execute '%bdelete|edit #|normal `"'
nmap <leader>bd :BufOnly<CR>

" disable highlighting
map <leader><space> :noh<CR>

" Enable autocompletion:
set wildmode=longest,list,full

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright

" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" indentlines for tabs
set listchars+=tab:│\       "

set list
" turn on spell check for markdown files
autocmd BufRead,BufNewFile *.md setlocal spell

" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e

" Remembers last position of the cursor
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" NEOVIM Specific
if has("nvim")
	set inccommand=nosplit
endif

" =========================================================
" Plugins
" =========================================================

" vim-markdown
" disable header folding
let g:vim_markdown_folding_disabled = 1

" do not use conceal feature, the implementation is not so good
let g:vim_markdown_conceal = 0

" disable math tex conceal feature
let g:tex_conceal = ""
let g:vim_markdown_math = 1

" support front matter of various format
let g:vim_markdown_frontmatter = 1  " for YAML format
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format

" vim-pandoc-syntax
" It is designed to work with vim-pandoc.
" To use it as a standalone plugin, add the following settings:
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

" gitgutter
" Update sign column every quarter second
set updatetime=100
" disable auto-set vars
let g:gitgutter_map_keys = 0
" Use fontawesome icons as signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

let g:gitgutter_override_sign_column_highlight = 1
highlight SignColumn guibg=bg
highlight SignColumn ctermbg=bg

" Jump between hunks
nmap <Leader>gn <Plug>(GitGutterNextHunk)
nmap <Leader>gp <Plug>(GitGutterPrevHunk)

" Hunk-add and hunk-revert for chunk staging
nmap <Leader>ga <Plug>(GitGutterStageHunk)
nmap <Leader>gu <Plug>(GitGutterUndoHunk)
nmap <leader>gd <Plug>(GitGutterPreviewHunk)

" Open vimagit pane
nnoremap <leader>gs :Magit<CR>

" ripgrep
let g:rg_command = 'rg --vimgrep -S'
nnoremap <C-_> :Rg<Cr>

map <leader>0 :set ft=html<CR>

" Goyo plugin makes text more readable when writing prose:
map <leader>go :Goyo \| set linebreak<CR>

" Nerd tree
map <leader>n :NERDTreeToggle<CR>
map <leader>m :NERDTreeFind<CR>
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" nerdcommenter config
let g:NERDSpaceDelims = 1

" clang format
let g:clang_format#auto_format = 0

" vim-go
let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"

" fzf
let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
nnoremap <c-p> :GFiles<cr>
nnoremap <c-y> :Buffer<cr>
let g:fzf_layout = { 'down': '~20%' }

" python syntax hl
let g:python_highlight_all = 1
