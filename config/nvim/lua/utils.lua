function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command)
  map('n', shortcut, command)
end

function imap(shortcut, command)
  map('i', shortcut, command)
end

function vmap(shortcut, command)
  map('v', shortcut, command)
end

function cmap(shortcut, command)
  map('c', shortcut, command)
end

function tmap(shortcut, command)
  map('t', shortcut, command)
end

vim.api.nvim_create_user_command('Note', function()
  local project_dir = vim.fs.dirname(vim.fs.find({ '.git' }, { upward = true })[1]) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(project_dir, ':t')
  local note_file = vim.env.HOME .. '/note/' .. project_name .. '.md'
  vim.fn.mkdir(vim.env.HOME .. '/note/', 'p')
  vim.cmd.vsplit()
  vim.api.nvim_set_current_buf(vim.fn.bufadd(note_file))
end, {})
