return {
  'rmagatti/goto-preview',
  keys = {
    { mode = "n", "<leader>gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",      desc = "pop up definition" },
    { mode = "n", "<leader>gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",  desc = "pop up implementation" },
    { mode = "n", "<leader>gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>",                desc = "close all pop up" },
    { mode = "n", "<leader>gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>",      desc = "pop up references" },
    { mode = "n", "<leader>gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "pop up type definition" },
    { mode = "n", "<leader>gpD", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",     desc = "pop up declaration" },
  },
  config = function()
    require('goto-preview').setup({})
  end
}
