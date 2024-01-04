return {
  'akinsho/toggleterm.nvim',
  keys = {
    { mode = "n", "<c-t>",       "<cmd>ToggleTerm dir=git_dir direction=float<CR>",      desc = "open terminal" },
    { mode = "n", "<leader>ttf", "<cmd>ToggleTerm dir=git_dir direction=float<CR>",      desc = "toggle terminal float" },
    { mode = "n", "<leader>tth", "<cmd>ToggleTerm dir=git_dir direction=horizontal<CR>", desc = "toggle terminal horizontal" },
    { mode = "t", "<c-t>",       "<cmd>ToggleTerm<CR>",                                  desc = "close terminal" },
  },
  config = function()
    require("toggleterm").setup({
      persist_size = false,
    })
  end,
}
