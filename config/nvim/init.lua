-- This is the main configuration file for Neovim.

-- Set leader key early
vim.g.mapleader = ","

-- Load config + plugins
require('options')
require('keymaps')
require('autocmds')
require('filetype')
require('plug')
require('plugins')
