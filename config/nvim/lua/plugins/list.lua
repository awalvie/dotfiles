local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- automatically add brackets
  use {
    "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  }
  -- surround things with different things
  use 'tpope/vim-surround'
  -- File navigator
  use 'scrooloose/nerdtree'
  -- Main theme for vim
  use "EdenEast/nightfox.nvim"
  -- Statusline theme for gruvbox
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  -- Plugin for quickly commenting out code
  use 'preservim/nerdcommenter'
  -- rip grep, yeah, I'm going into the corner
  use 'jremmen/vim-ripgrep'
  -- git gutter, finally yes, I need to clean up this config sometime
  use 'airblade/vim-gitgutter'
  -- sit on that tree
  use 'nvim-treesitter/nvim-treesitter'
  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  -- lspconfig
  use 'neovim/nvim-lspconfig'
  -- yaml folding
  use 'pedrohdz/vim-yaml-folds'
  -- completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  -- become a buddhist
  use 'folke/zen-mode.nvim'

  -- Language Plugins
  use 'fatih/vim-go'
  use 'towolf/vim-helm'

  -- Copilot
  use 'github/copilot.vim'
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
