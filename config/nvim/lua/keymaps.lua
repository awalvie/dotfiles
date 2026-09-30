require("utils")

-- don't jump when using *
nmap("*", "*<c-o>")

-- keep search matches in the middle of the window
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

-- buffer navigation and management
nmap("<leader>l", "<cmd>bnext<CR>") -- Move to the next buffer
nmap("<leader>h", "<cmd>bprevious<CR>") -- Move to the previous buffer
vim.keymap.set("n", "<leader>bq", function()
	Snacks.bufdelete()
end) -- Delete current buffer
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete.other()
end) -- Delete all buffers but the current one

-- tab navigation
vim.keymap.set("n", "<leader>dq", ":diffoff! | only<CR>") -- Close all diff windows when using Gitsigns.diffthis()

-- Begining & End of line in Normal mode
nmap("H", "^")
nmap("L", "g_")

-- disable highlighting
nmap("<leader><space>", "<cmd>noh<CR>")
nmap("<leader>sm", "<cmd>messages<CR>")

-- Built-in Neovim 0.12 undo tree UI
vim.keymap.set("n", "<leader>uu", function()
	vim.cmd("packadd nvim.undotree")
	vim.cmd("Undotree")
end, { desc = "Open Undotree" })

-- Ex mode is fucking dumb
nmap("Q", "<Nop>")

-- Restart neovim
nmap("<leader>rn", "<cmd>restart<CR>")

-- Easy window split; C-w v -> <leader>wv, C-w s -> <leader>ws
nmap("<leader>wv", "<C-w>v")
nmap("<leader>ws", "<C-w>s")

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
end, { silent = true })
