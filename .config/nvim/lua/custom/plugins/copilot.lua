if vim.env.USE_COPILOT == "true" then
    return {
        "github/copilot.vim",
        lazy = false,
    }
else
    return {}
end
