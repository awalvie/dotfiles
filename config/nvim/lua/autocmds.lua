local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

-- Disable automatic commenting on newline
autocmd("FileType", {
	group = augroup("CustomizeFormatOptions", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove("c")
		vim.opt_local.formatoptions:remove("r")
		vim.opt_local.formatoptions:remove("o")
	end,
})

-- Trim trailing whitespace on save
autocmd("BufWritePre", {
	group = augroup("TrimTrailingWhitespace", { clear = true }),
	pattern = "*",
	command = "%s/\\s\\+$//e",
})

-- Restore cursor position when reopening files
autocmd({ "BufReadPost" }, {
	group = augroup("RestoreCursorPosition", { clear = true }),
	pattern = "*",
	callback = function(args)
		local mark = api.nvim_buf_get_mark(args.buf, '"')
		local lnum = mark[1]
		local last_line = api.nvim_buf_line_count(args.buf)
		if lnum > 1 and lnum <= last_line then
			-- Restore cursor and recenter
			api.nvim_win_set_cursor(0, mark)
			vim.cmd("normal! zvzz")
		end
	end,
})
