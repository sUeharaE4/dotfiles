return {
    {
        "phpactor/phpactor",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required to update phpactor
            "neovim/nvim-lspconfig", -- required to automaticly register lsp serveur
        },
    },
    {
        "adalessa/laravel.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-dotenv",
            "MunifTanjim/nui.nvim",
            "nvimtools/none-ls.nvim",
            "kevinhwang91/promise-async"
        },
        cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
        keys = {
            { "<leader>la", ":Laravel artisan<cr>" },
            { "<leader>lr", ":Laravel routes<cr>" },
            { "<leader>lm", ":Laravel related<cr>" },
        },
        event = { "VeryLazy" },
        config = true,
    },
}
