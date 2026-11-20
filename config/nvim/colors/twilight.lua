-- Twilight, after the TextMate theme (dark only). Tree-sitter and LSP
-- captures link to the standard groups by default, so those cover the code.
vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "twilight"

local c = {
	bg = "#141414",
	panel = "#1b1b1b",
	line = "#1f1f1f",
	overlay = "#262626",
	selection = "#323537",
	border = "#3a3a3a",
	comment = "#5f5a60",
	subtle = "#a7a7a7",
	fg = "#f8f8f8",
	tan = "#cda869", -- keywords, storage
	brown = "#9b703f", -- functions, entities
	green = "#8f9d6a", -- strings
	orange = "#cf6a4c", -- constants, numbers
	blue = "#7587a6", -- variables, support
	mauve = "#9b859d", -- types, classes
	yellow = "#f9ee98", -- support functions
	sky = "#afc4db", -- escapes, regex
	red = "#e5534b",
}

local groups = {
	-- editor
	Normal = { fg = c.fg, bg = c.bg },
	NormalFloat = { fg = c.fg, bg = c.panel },
	FloatBorder = { fg = c.border, bg = c.panel },
	FloatTitle = { fg = c.tan, bg = c.panel, bold = true },
	Cursor = { fg = c.bg, bg = c.fg },
	CursorLine = { bg = c.line },
	CursorLineNr = { fg = c.tan, bold = true },
	LineNr = { fg = c.comment },
	SignColumn = { bg = c.bg },
	ColorColumn = { bg = c.line },
	Visual = { bg = c.selection },
	Search = { fg = c.bg, bg = c.tan },
	IncSearch = { fg = c.bg, bg = c.orange },
	CurSearch = { link = "IncSearch" },
	MatchParen = { fg = c.yellow, bold = true },
	Pmenu = { fg = c.fg, bg = c.overlay },
	PmenuSel = { fg = c.fg, bg = c.selection, bold = true },
	PmenuSbar = { bg = c.overlay },
	PmenuThumb = { bg = c.border },
	StatusLine = { fg = c.fg, bg = c.overlay },
	StatusLineNC = { fg = c.comment, bg = c.panel },
	TabLine = { fg = c.subtle, bg = c.panel },
	TabLineSel = { fg = c.fg, bg = c.overlay, bold = true },
	TabLineFill = { bg = c.panel },
	WinSeparator = { fg = c.border },
	VertSplit = { link = "WinSeparator" },
	Folded = { fg = c.subtle, bg = c.panel },
	NonText = { fg = c.border },
	Whitespace = { fg = c.border },
	SpecialKey = { fg = c.border },
	EndOfBuffer = { fg = c.bg },
	Directory = { fg = c.blue },
	Title = { fg = c.tan, bold = true },
	ErrorMsg = { fg = c.red },
	WarningMsg = { fg = c.tan },
	MoreMsg = { fg = c.green },
	Question = { fg = c.green },
	WildMenu = { link = "PmenuSel" },

	-- syntax
	Comment = { fg = c.comment, italic = true },
	Constant = { fg = c.orange },
	String = { fg = c.green },
	Character = { fg = c.green },
	Number = { fg = c.orange },
	Boolean = { fg = c.orange },
	Float = { fg = c.orange },
	Identifier = { fg = c.blue },
	Function = { fg = c.brown },
	Statement = { fg = c.tan },
	Keyword = { fg = c.tan },
	Conditional = { fg = c.tan },
	Repeat = { fg = c.tan },
	Operator = { fg = c.tan },
	Exception = { fg = c.tan },
	PreProc = { fg = c.yellow },
	Include = { fg = c.tan },
	Type = { fg = c.mauve },
	StorageClass = { fg = c.tan },
	Structure = { fg = c.mauve },
	Special = { fg = c.sky },
	SpecialChar = { fg = c.sky },
	Delimiter = { fg = c.subtle },
	Tag = { fg = c.tan },
	Underlined = { fg = c.blue, underline = true },
	Todo = { fg = c.bg, bg = c.tan, bold = true },
	Error = { fg = c.red },
	["@variable"] = { fg = c.fg },
	["@variable.builtin"] = { fg = c.blue },
	["@property"] = { fg = c.blue },
	["@function.builtin"] = { fg = c.yellow },
	["@constructor"] = { fg = c.mauve },
	["@punctuation"] = { fg = c.subtle },
	["@markup.heading"] = { fg = c.tan, bold = true },
	["@markup.link"] = { fg = c.blue, underline = true },
	["@markup.raw"] = { fg = c.green },

	-- diagnostics and diffs
	DiagnosticError = { fg = c.red },
	DiagnosticWarn = { fg = c.tan },
	DiagnosticInfo = { fg = c.blue },
	DiagnosticHint = { fg = c.sky },
	DiagnosticUnderlineError = { undercurl = true, sp = c.red },
	DiagnosticUnderlineWarn = { undercurl = true, sp = c.tan },
	DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
	DiagnosticUnderlineHint = { undercurl = true, sp = c.sky },
	DiffAdd = { bg = "#1f2a1a" },
	DiffChange = { bg = "#1f2330" },
	DiffDelete = { fg = c.red, bg = "#2e1a17" },
	DiffText = { bg = "#2c3550" },
	Added = { fg = c.green },
	Changed = { fg = c.blue },
	Removed = { fg = c.red },
}

for name, spec in pairs(groups) do
	vim.api.nvim_set_hl(0, name, spec)
end

local ansi = {
	"#141414", "#cf6a4c", "#8f9d6a", "#cda869", "#7587a6", "#9b859d", "#afc4db", "#a7a7a7",
	"#5f5a60", "#cf6a4c", "#8f9d6a", "#f9ee98", "#7587a6", "#9b859d", "#afc4db", "#f8f8f8",
}
for i, col in ipairs(ansi) do
	vim.g["terminal_color_" .. (i - 1)] = col
end
