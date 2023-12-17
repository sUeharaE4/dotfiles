return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  config = function ()
    require('barbar').setup({
    })
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    map('n', '<C-j>', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<C-k>', '<Cmd>BufferNext<CR>', opts)
  end
}
