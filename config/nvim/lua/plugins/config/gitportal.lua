local gitportal = require("gitportal")

gitportal.setup({
	always_include_current_line = true, -- Include the current line in permalinks by default
})

-- Key mappings for GitPortal functions:

-- Opens the current file in your browser at the correct branch/commit.
-- When in visual mode, selected lines are included in the permalink.
vim.keymap.set("n", "<leader>go", gitportal.open_file_in_browser)
vim.keymap.set("v", "<leader>go", gitportal.open_file_in_browser)

-- Opens a Githost link directly in Neovim, optionally switching to the branch/commit.
vim.keymap.set("n", "<leader>ig", gitportal.open_file_in_neovim)

-- Generates and copies the permalink of your current file to your clipboard.
-- When in visual mode, selected lines are included in the permalink.
vim.keymap.set("n", "<leader>gc", gitportal.copy_link_to_clipboard)
vim.keymap.set("v", "<leader>gc", gitportal.copy_link_to_clipboard)
