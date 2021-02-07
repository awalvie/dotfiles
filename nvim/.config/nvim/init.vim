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
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" surround things with different things
Plug 'tpope/vim-surround'
" Fuzzy file finder
Plug 'kien/ctrlp.vim'
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
" rip grep, yeah, I'm going into the corner
Plug 'jremmen/vim-ripgrep'
" yeah, yeah, I know I'm retarded for not having using fugutive until now
Plug 'tpope/vim-fugitive'

" Language Plugins
" HTML autoclose tag
Plug 'alvan/vim-closetag'
" Formatter for C code
Plug 'rhysd/vim-clang-format'
" golang plugin for vim
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

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

" ripgrep
let g:rg_command = 'rg --vimgrep -S'
nnoremap <C-_> :Rg<Space>

map <leader>0 :set ft=html<CR>

" Goyo plugin makes text more readable when writing prose:
map <leader>g :Goyo \| set linebreak<CR>

" Nerd tree
map <leader>n :NERDTreeToggle<CR>
map <leader>m :NERDTreeFind<CR>
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" open by default
autocmd StdinReadPre * let s:std_in=1
" make it slightly perttier
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" nerdcommenter config
let g:NERDSpaceDelims = 1

" clang format
let g:clang_format#auto_format = 0

" vim-go
let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"

" by default navigate buffers with ctrlP
nnoremap <silent> <C-y> :CtrlPBuffer<CR>

" Coc settings
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

" dedicated path for neovim virutalenv
let g:python3_host_prog = '/home/awalvie/.pyenv/versions/neovim3/bin/python3'
