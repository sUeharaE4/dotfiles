if vim.env.USE_COPILOT then return {} end

return {
  {
    'Exafunction/codeium.vim',
    event = 'BufEnter'
  }
}
