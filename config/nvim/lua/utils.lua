-- desc is optional; mini.clue shows it in the key hints
function map(mode, shortcut, command, desc)
	vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true, desc = desc })
end

function nmap(shortcut, command, desc)
	map("n", shortcut, command, desc)
end

function imap(shortcut, command)
	map("i", shortcut, command)
end

function vmap(shortcut, command)
	map("v", shortcut, command)
end

function cmap(shortcut, command)
	map("c", shortcut, command)
end

function tmap(shortcut, command)
	map("t", shortcut, command)
end
