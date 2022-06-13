require('utils')

-- don't jump when using *
nmap('*', '*<c-o>')

-- keep search matches in the middle of the window
nmap('n', 'nzzzv')
nmap('N', 'Nzzzv')

-- buffer navigation and management
nmap('<leader>l', '<cmd>bnext<CR>') -- Move to the next buffer
nmap('<leader>h', '<cmd>bprevious<CR>') -- Move to the previous buffer
nmap('<leader>bq', '<cmd>bp <BAR> bd #<CR>') -- Delete current buffer
nmap('<leader>bd', '<cmd>bd|e#|bd#<CR>') -- Delete all buffers but the last one

-- Begining & End of line in Normal mode
nmap('H', '^')
nmap('L', 'g_')

-- disable highlighting
nmap('<leader><space>', '<cmd>noh<CR>')

-- Ex mode is fucking dumb
nmap('Q', '<Nop>')

-- Easy window split; C-w v -> vv, C-w - s -> ss
nmap('vv', '<C-w>v')
nmap('ss', '<C-w>s')
vim.o.splitbelow = true -- when splitting horizontally, move coursor to lower pane
vim.o.splitright = true -- when splitting vertically, mnove coursor to right pane

-- Shortcutting split navigation, saving a keypress:
nmap('<C-h>', '<C-w>h')
nmap('<C-j>', '<C-w>j')
nmap('<C-k>', '<C-w>k')
nmap('<C-l>', '<C-w>l')
