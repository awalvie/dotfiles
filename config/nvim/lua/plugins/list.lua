local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","

require("lazy").setup({
  -- automatically add brackets
  {
    'm4xshen/autoclose.nvim',
    config = function()
      require("autoclose").setup({
        options = {
          disable_command_mode = true,
          pair_spaces = true,
        }
      })
    end,
  },
  -- surround things with different things
  'tpope/vim-surround',
  -- File navigator
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }
  },
  -- Main theme for vim
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({})
      vim.cmd.colorscheme("nord")
    end,
  },
  install = {
    colorscheme = { "nord" },
  },
  -- Statusline theme for gruvbox
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  { 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
  -- Comform formatting
  'stevearc/conform.nvim',
  -- Indent guide
  'lukas-reineke/indent-blankline.nvim',
  -- Plugin for quickly commenting out code
  {
    'numToStr/Comment.nvim',
    lazy = false,
  },
  -- rip grep, yeah, I'm going into the corner
  'jremmen/vim-ripgrep',
  -- git gutter, finally yes, I need to clean up this config sometime
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "<leader>gn", gs.next_hunk, "Next Hunk")
        map("n", "<leader>gp", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ga", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>gu", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gA", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gU", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gd", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>gbl", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gD", gs.diffthis, "Diff This")
        -- map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
        -- map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  -- I like big diffs and I cannot lie
  {
    "sindrets/diffview.nvim",
    lazy = true,
  }, -- optional - Diff integration
  -- big git repos and bigger git plugins
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
  },
  -- lazygit in neovim
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  -- sit on that tree
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' }
  },
  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        -- Build command stolen from lazy's config
        -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#lazynvim
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
      },
      {
        "AckslD/nvim-neoclip.lua",
        dependencies = {
          { 'kkharji/sqlite.lua', module = 'sqlite' },
          -- you'll need at least one of these
          -- {'nvim-telescope/telescope.nvim'},
          -- {'ibhagwan/fzf-lua'},
        },
        config = function()
          require('neoclip').setup()
        end,
      },
      'fdschmidt93/telescope-egrepify.nvim',
    },

  },
  -- lspconfig
  'williamboman/mason.nvim',
  'neovim/nvim-lspconfig',

  -- completion
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'hrsh7th/nvim-cmp',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',

  -- Copilot
  'github/copilot.vim',

  -- maker of plugins, breaker of vim
  { "folke/neodev.nvim",       opts = {} },

  -- figure out what I'm doing
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
    }
  }
})
