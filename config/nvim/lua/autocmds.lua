local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

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

-- Equalize splits on terminal resize
autocmd("VimResized", {
	group = augroup("EqualizeOnResize", { clear = true }),
	callback = function()
		vim.cmd("wincmd =")
	end,
})

-- Quit when a tab closes (e.g. neogit) and no file buffers are left to go back to
autocmd("TabClosed", {
	group = augroup("QuitWhenNothingLeft", { clear = true }),
	callback = function()
		vim.schedule(function()
			for _, buf in ipairs(api.nvim_list_bufs()) do
				if vim.bo[buf].buflisted or vim.bo[buf].modified then
					return
				end
			end
			vim.cmd("qa")
		end)
	end,
})

-- Close Undotree with q
autocmd("FileType", {
	group = augroup("UndotreeKeymaps", { clear = true }),
	pattern = "undotree",
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
	end,
})
