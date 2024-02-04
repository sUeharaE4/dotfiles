if vim.env.USE_COPILOT == "true" then
    return {}
end

return {
    {
        "Exafunction/codeium.vim",
        event = "BufEnter",
    },
}
