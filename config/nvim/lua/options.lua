HOME = os.getenv("HOME")

-- Skips having to prepend "vim." every time
local o = vim.opt
local g = vim.g

-- Global Options --
--------------------

-- Mapping waiting time
o.timeout = true
o.timeoutlen = 500
o.ttimeout = true
o.ttimeoutlen = 100

-- Display
o.relativenumber = true
o.sidescroll = 3
o.wrap = false -- do not wrap lines even if very long
o.scrolloff = 3 -- always show 3 rows from edge of the screen
o.eol = false -- show if there's no eol char
o.updatetime = 100
vim.opt.foldcolumn = "0"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 3
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
o.foldenable = false
o.listchars = {
	tab = "│ ",
	nbsp = "␣",
	trail = "·",
	extends = ">",
	precedes = "<",
}
o.list = true
o.winborder = "rounded" -- border for floating windows
o.splitbelow = true -- when splitting horizontally, move coursor to lower pane
o.splitright = true -- when splitting vertically, mnove coursor to right pane
o.lazyredraw = true -- redraw only when needed, not after every command

-- Search
o.ignorecase = true -- ignore letter case when searching
o.smartcase = true -- case insentive unless capitals used in search

-- White characters
o.tabstop = 4 -- 1 tab = 4 spaces
o.shiftwidth = 4 -- indentation rule

-- Editing
o.clipboard = "unnamedplus"

-- over ssh, yank to the local clipboard via OSC 52, not the remote host's
if os.getenv("SSH_TTY") then
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
	}
end

-- Backup files
o.backup = true -- use backup files
o.writebackup = false
o.swapfile = false -- do not use swap file
o.undodir = HOME .. "/.tmp/undo//" -- undo files
o.backupdir = HOME .. "/.tmp/backup//" -- backups

-- Themeing
g.nord_underline = 1
g.nord_italic = 1
g.nord_italic_comments = 1
o.termguicolors = true

-- Commands mode
o.wildignore =
	"deps,.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc"
o.completeopt = { "menu", "menuone", "noselect" }
