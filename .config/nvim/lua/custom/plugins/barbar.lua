return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    {mode = "n", "<leader>bp", "<cmd>BufferPin<CR>", desc = "BufferPin"},
  },
  config = function ()
    require('barbar').setup({
    })
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    map('n', '<C-j>', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<C-k>', '<Cmd>BufferNext<CR>', opts)
    map('n', '<leader>bp', '<Cmd>BufferNext<CR>', opts)
  end
}
