return {
  "Mofiqul/vscode.nvim",
  config = function()
    require("vscode").setup({
      style = 'dark',
    })
    require('vscode').load()
  end
}
