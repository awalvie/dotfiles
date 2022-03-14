HOME = os.getenv("HOME")

local o = vim.opt
local g = vim.g
local cmd = vim.cmd

-- Global Options --
--------------------

-- Leader Key
g.mapleader = ","

-- basic settings
o.encoding = "utf-8"
o.backspace = "indent,eol,start" -- backspace works on every char in insert mode
o.history = 1000

-- Mapping waiting time
vim.o.timeout = false
vim.o.ttimeout = true
vim.o.ttimeoutlen = 100
vim.o.synmaxcol = 300 -- stop syntax highlight after x lines for performance

-- Display
o.relativenumber = true
o.sidescroll = 3
o.wrap = false -- do not wrap lines even if very long
o.scrolloff = 3 -- always show 3 rows from edge of the screen
o.eol = false -- show if there's no eol char
o.updatetime = 100

-- Search
o.incsearch = true -- starts searching as soon as typing, without enter needed
o.ignorecase = true -- ignore letter case when searching
o.smartcase = true -- case insentive unless capitals used in search

-- White characters
o.tabstop = 4 -- 1 tab = 4 spaces
o.shiftwidth = 4 -- indentation rule
o.autoindent = true

-- Editing
o.clipboard = 'unnamedplus'

-- Backup files
o.backup = true -- use backup files
o.writebackup = false
o.swapfile = false -- do not use swap file
o.undodir = HOME .. '/.tmp/undo//'     -- undo files
o.backupdir = HOME .. '/.tmp/backup//' -- backups
o.directory = '/.tmp/swap//'   -- swap files

-- Themeing
o.background = 'dark'
cmd([[
	colorscheme gruvbox
]])
g.gruvbox_italic = 1
o.termguicolors = true
g.grubbox_italic = 1

-- Commands mode
o.wildmenu = true -- on TAB, complete options for system command
o.wildignore = 'deps,.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc'

-- Disables automatic commenting on newline:
cmd([[
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
]])

-- Automatically deletes all trailing whitespace on save.
cmd([[
	autocmd BufWritePre * %s/\s\+$//e
]])

-- Remembers last position of the cursor
cmd([[
	if has("autocmd")
	  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
	endif
]])
