require("utils")

-- don't jump when using *
nmap("*", "*<c-o>")

-- keep search matches in the middle of the window
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

-- buffer navigation and management
nmap("<leader>l", "<cmd>bnext<CR>", "Next buffer")
nmap("<leader>h", "<cmd>bprevious<CR>", "Previous buffer")
vim.keymap.set("n", "<leader>bq", function()
	-- the last file: quit nvim (asks to save) instead of opening an empty buffer
	local cur = vim.api.nvim_get_current_buf()
	local others = vim.tbl_filter(function(b)
		return b.bufnr ~= cur
	end, vim.fn.getbufinfo({ buflisted = 1 }))
	if vim.bo[cur].buflisted and #others == 0 then
		vim.cmd("confirm qall")
	else
		Snacks.bufdelete()
	end
end, { desc = "Delete buffer (quit on the last)" })
-- quit nvim, whatever windows are open (asks about unsaved changes)
nmap("<leader>q", "<cmd>confirm qall<CR>", "Quit nvim")
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete.other()
end, { desc = "Delete other buffers" })

-- tab navigation
-- close all diff windows after Gitsigns.diffthis()
vim.keymap.set("n", "<leader>dq", ":diffoff! | only<CR>", { desc = "Close diff" })

-- Begining & End of line in Normal mode
nmap("H", "^")
nmap("L", "g_")

-- disable highlighting
nmap("<leader><space>", "<cmd>noh<CR>", "Clear search highlight")
nmap("<leader>sm", "<cmd>messages<CR>", "Show messages")

-- Built-in Neovim 0.12 undo tree UI
vim.keymap.set("n", "<leader>uu", function()
	vim.cmd("packadd nvim.undotree")
	vim.cmd("Undotree")
end, { desc = "Open Undotree" })

-- Ex mode is fucking dumb
nmap("Q", "<Nop>")

-- Restart neovim
nmap("<leader>rn", "<cmd>restart<CR>", "Restart nvim")

-- Easy window split; C-w v -> <leader>wv, C-w s -> <leader>ws
nmap("<leader>wv", "<C-w>v", "Split vertically")
nmap("<leader>ws", "<C-w>s", "Split horizontally")

-- Shortcutting split navigation, saving a keypress:
nmap("<C-h>", "<C-w>h")
nmap("<C-j>", "<C-w>j")
nmap("<C-k>", "<C-w>k")
nmap("<C-l>", "<C-w>l")

-- Copy current file path to clipboard
vim.keymap.set("n", "<leader>cp", function()
	local rel_path = vim.fn.expand("%") -- Get relative path
	vim.fn.setreg("+", rel_path) -- Copy to system clipboard
	print("Copied relative path: " .. rel_path) -- Print message
end, { silent = true, desc = "Copy file path" })
