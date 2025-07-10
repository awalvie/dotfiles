HOME = os.getenv("HOME")

-- Skips having to prepend "vim." every time
local o = vim.opt
local g = vim.g
local cmd = vim.cmd

-- Global Options --
--------------------

-- basic settings
o.backspace = "indent,eol,start" -- backspace works on every char in insert mode
o.history = 1000

-- Mapping waiting time
o.timeout = false
o.ttimeout = true
o.ttimeoutlen = 100

-- Display
o.relativenumber = true
o.sidescroll = 3
o.wrap = false        -- do not wrap lines even if very long
o.scrolloff = 3       -- always show 3 rows from edge of the screen
o.eol = false         -- show if there's no eol char
o.updatetime = 100
o.foldlevelstart = 20 -- unfold all file when opening
o.foldmethod = "expr"
o.foldexpr = "require('vim.treesitter').foldexpr()"
o.foldenable = false
o.listchars = {
	tab = '│ ',
	nbsp = '␣',
	trail = '·',
	extends = '>',
	precedes = '<',
}
o.list = true
o.list = true
o.winborder = 'rounded' -- border for floating windows
o.lazyredraw = true     -- redraw only when needed, not after every command
o.hlsearch = true       -- highlight search results

-- Search
o.incsearch = true  -- starts searching as soon as typing, without enter needed
o.ignorecase = true -- ignore letter case when searching
o.smartcase = true  -- case insentive unless capitals used in search

-- White characters
o.tabstop = 4    -- 1 tab = 4 spaces
o.shiftwidth = 4 -- indentation rule
o.autoindent = true

-- Editing
o.clipboard = 'unnamedplus'

-- Backup files
o.backup = true                        -- use backup files
o.writebackup = false
o.swapfile = false                     -- do not use swap file
o.undodir = HOME .. '/.tmp/undo//'     -- undo files
o.backupdir = HOME .. '/.tmp/backup//' -- backups
o.directory = '/.tmp/swap//'           -- swap files
o.hidden = true

-- Themeing
g.nord_underline = 1
g.nord_italic = 1
g.nord_italic_comments = 1
o.termguicolors = true

-- Commands mode
o.wildmenu = true -- on TAB, complete options for system command
o.wildignore =
'deps,.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc'
o.completeopt = { 'menu', 'menuone', 'noselect' }

-- Python config
g.python3_host_prog = '/home/hyperion/.pyenv/versions/vim/bin/python3'
g.python_host_prog = '/home/hyperion/.pyenv/versions/vim/bin/python'
