-- Function to check for a project root in the current and parent directories
local function recursive_find_project_root(start_path, folder_name)
    local current_path = start_path

    while current_path ~= "" do
        local target_path = string.format("%s/%s", current_path, folder_name)
        if vim.fn.isdirectory(target_path) == 1 then
            return target_path
        end

        -- Move up to the parent directory
        local parent_path = vim.fn.fnamemodify(current_path, ":h")
        if parent_path == current_path then
            break
        end
        current_path = parent_path
    end
    return nil -- No virtual environment found
end

-- Helper function to check if specified LSP is attached to the current buffer
local function is_lsp_attached(lsp_name)
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        if client.name == lsp_name and vim.lsp.buf_is_attached(0, client.id) then
            return true
        end
    end
    return false
end

-- Function that waits for specified LSP to attach and then calls the provided callback
local function wait_for_lsp(lsp_name, callback)
    local timer = vim.uv.new_timer()
    local interval = 100 -- Check every 100ms
    local max_attempts = 50 -- Maximum attempts before timeout (e.g., 5 seconds)

    local attempts = 0

    -- Start the polling loop
    if timer ~= nil then
        timer:start(
            0,
            interval,
            vim.schedule_wrap(function()
                attempts = attempts + 1

                if is_lsp_attached(lsp_name) then
                    -- If LSP is attached, stop the timer and run the callback
                    timer:stop()
                    if not timer:is_closing() then
                        timer:close()
                    end
                    callback()
                elseif attempts >= max_attempts then
                    -- Stop checking after max attempts (timeout)
                    timer:stop()
                    if not timer:is_closing() then
                        timer:close()
                    end
                    vim.notify(string.format("%s not activated in time", lsp_name), vim.log.levels.WARN)
                end
            end)
        )
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.py",
    callback = function()
        wait_for_lsp("pyright", function()
            local current_file_path = vim.fn.expand("%:p:h")
            local venv_path = recursive_find_project_root(current_file_path, ".venv")

            if venv_path == nil then
                vim.notify("No virtual environment found in current or parent directories.", vim.log.levels.WARN)
                return
            end

            require("venv-selector").activate_from_path(string.format("%s/bin/python", venv_path))
        end)
    end,
})

return {
    "linux-cultist/venv-selector.nvim",
    lazy = false,
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        "mfussenegger/nvim-dap-python", --optional
        { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    -- branch = "regexp",
    opts = {
        -- Your options go here
        name = ".venv",
        -- auto_refresh = false
    },
    -- event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
        -- Keymap to open VenvSelector to pick a venv.
        { "<leader>pvs", "<cmd>VenvSelect<cr>" },
        -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
        { "<leader>pvc", "<cmd>VenvSelectCached<cr>" },
    },
}
