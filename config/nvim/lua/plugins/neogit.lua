return {
  'NeogitOrg/neogit',
  cmd = 'Neogit',
  keys = {
    { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit' },
    { '<leader>gl', '<cmd>NeogitLog %<cr>', desc = 'Git log (current file)' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  config = function()
    require("neogit").setup({
      kind = "split_below_all",
      height = 0.4,
      integrations = {
        diffview = true,
        snacks = true,
      },
    })
  end,
}
