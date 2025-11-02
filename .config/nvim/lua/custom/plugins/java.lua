local Util = require("lazyvim.util")

-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local function extend_or_override(config, custom, ...)
    if type(custom) == "function" then
        config = custom(config, ...) or config
    elseif custom then
        config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
    end
    return config
end

local java_info = {
    exec = nil,
    ok = nil,
    message = nil,
    warned = false,
}

local function resolve_java_exec()
    if java_info.exec ~= nil then
        return java_info.exec
    end

    local candidate = nil
    if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= "" then
        local home_exec = vim.env.JAVA_HOME .. "/bin/java"
        if vim.fn.executable(home_exec) == 1 then
            candidate = home_exec
        end
    end

    if not candidate then
        local path_exec = vim.fn.exepath("java")
        if path_exec ~= "" then
            candidate = path_exec
        end
    end

    java_info.exec = candidate
    return java_info.exec
end

return {
    -- Add java to treesitter.
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "java" })
        end,
    },

    -- Ensure java debugger and test packages are installed.
    {
        "mfussenegger/nvim-dap",
        optional = true,
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = function(_, opts)
                    opts.ensure_installed = opts.ensure_installed or {}
                    vim.list_extend(opts.ensure_installed, { "java-test", "java-debug-adapter" })
                end,
            },
        },
    },

    -- Set up nvim-jdtls to attach to java files.
    {
        "mfussenegger/nvim-jdtls",
        dependencies = { "folke/which-key.nvim" },
        ft = java_filetypes,
        opts = function()
            return {
                -- How to find the root dir for a given filename. The default comes from
                -- lspconfig which provides a function specifically for java projects.
                root_dir = require("lspconfig.configs.jdtls").default_config.root_dir,

                -- How to find the project name for a given root dir.
                project_name = function(root_dir)
                    return root_dir and vim.fs.basename(root_dir)
                end,

                -- Where are the config and workspace dirs for a project?
                jdtls_config_dir = function(project_name)
                    return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
                end,
                jdtls_workspace_dir = function(project_name)
                    return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
                end,

                -- How to run jdtls. This can be overridden to a full java command-line
                -- if the Python wrapper script doesn't suffice.
                cmd = { vim.fn.exepath("jdtls") },
                full_cmd = function(opts, fname)
                    fname = fname or vim.api.nvim_buf_get_name(0)
                    local root_dir = opts.root_dir and opts.root_dir(fname) or nil
                    if not root_dir or root_dir == "" then
                        root_dir = vim.loop.cwd()
                    end

                    local project_name = opts.project_name and opts.project_name(root_dir) or nil
                    if not project_name or project_name == "" then
                        project_name = vim.fs.basename(root_dir)
                    end
                    if not project_name or project_name == "" then
                        local fallback_source = fname ~= "" and fname or root_dir
                        project_name = vim.fn.fnamemodify(fallback_source, ":p:h:t")
                    end
                    if not project_name or project_name == "" then
                        project_name = "default"
                    end

                    local java_exec = resolve_java_exec()
                    if not java_exec then
                        vim.notify(
                            "Unable to locate a Java executable in PATH or via JAVA_HOME. Skipping jdtls startup.",
                            vim.log.levels.ERROR
                        )
                        return nil, root_dir
                    end

                    if java_info.ok == nil then
                        local version_output = vim.fn.systemlist(java_exec .. " -version 2>&1")
                        local version_line = version_output[1] or version_output[2] or ""
                        local version_number = version_line:match('version "([%d%.]+)')
                        local major_version = version_number and version_number:match('^(%d+)')
                        if major_version and tonumber(major_version) < 21 then
                            java_info.ok = false
                            java_info.message = string.format(
                                "jdtls requires Java 21+. Detected %s (%s)",
                                java_exec,
                                version_line
                            )
                            java_info.warned = false
                        else
                            java_info.ok = true
                            java_info.warned = false
                        end
                    end

                    if java_info.ok == false then
                        if not java_info.warned then
                            vim.notify(java_info.message, vim.log.levels.ERROR)
                            java_info.warned = true
                        end
                        return nil, root_dir
                    end

                    local jdtls_root = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
                    local equinox_launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar", true)
                    equinox_launcher = vim.split(equinox_launcher, "\n", { plain = true })[1] or ""

                    if equinox_launcher == "" then
                        vim.notify("Could not locate the Eclipse Equinox launcher for jdtls.", vim.log.levels.ERROR)
                        return nil, root_dir
                    end

                    local uname = vim.loop.os_uname().sysname
                    local platform_config = "config_linux"
                    if uname == "Darwin" then
                        platform_config = "config_mac"
                    elseif uname == "Windows_NT" then
                        platform_config = "config_win"
                    end

                    local default_config_dir = table.concat({ jdtls_root, platform_config }, "/")
                    local config_dir = opts.jdtls_config_dir and opts.jdtls_config_dir(project_name) or nil
                    if config_dir and config_dir ~= "" then
                        if vim.fn.glob(config_dir .. "/config.ini") == "" then
                            config_dir = default_config_dir
                        end
                    else
                        config_dir = default_config_dir
                    end

                    local workspace_dir = opts.jdtls_workspace_dir(project_name)
                    if workspace_dir and workspace_dir ~= "" then
                        vim.fn.mkdir(workspace_dir, "p")
                    end

                    local cmd = { java_exec }
                    vim.list_extend(cmd, {
                        "-javaagent:" .. jdtls_root .. "/lombok.jar",
                        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                        "-Dosgi.bundles.defaultStartLevel=4",
                        "-Declipse.product=org.eclipse.jdt.ls.core.product",
                        "--add-opens", "java.base/java.util=ALL-UNNAMED",
                        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                        "-jar", equinox_launcher,
                        "-configuration", config_dir,
                        "-data", workspace_dir,
                    })
                    return cmd, root_dir
                end,

                -- These depend on nvim-dap, but can additionally be disabled by setting false here.
                dap = { hotcodereplace = "auto", config_overrides = {} },
                test = true,
            }
        end,
        config = function()
            local opts = Util.opts("nvim-jdtls") or {}

            -- Find the extra bundles that should be passed on the jdtls command-line
            -- if nvim-dap is enabled with java debug/test.
            local mason_registry = require("mason-registry")
            local mason_settings = require("mason.settings")
            local mason_root = mason_settings.current.install_root_dir

            local function package_install_path(pkg_name)
                local ok, pkg = pcall(mason_registry.get_package, pkg_name)
                if not ok then
                    return nil
                end
                return table.concat({ mason_root, "packages", pkg.name }, "/")
            end

            local bundles = {} ---@type string[]
            local function add_bundles_from(pattern)
                if not pattern then
                    return
                end
                for _, bundle in ipairs(vim.split(vim.fn.glob(pattern), "\n")) do
                    if bundle ~= "" then
                        table.insert(bundles, bundle)
                    end
                end
            end
            if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
                local java_dbg_path = package_install_path("java-debug-adapter")
                add_bundles_from(java_dbg_path and (java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"))
                -- java-test also depends on java-debug-adapter.
                if opts.test and mason_registry.is_installed("java-test") then
                    local java_test_path = package_install_path("java-test")
                    add_bundles_from(java_test_path and (java_test_path .. "/extension/server/*.jar"))
                end
            end

            local function attach_jdtls()
                local fname = vim.api.nvim_buf_get_name(0)

                -- Configuration can be augmented and overridden by opts.jdtls
                local full_cmd, resolved_root = opts.full_cmd(opts, fname)
                if not full_cmd then
                    return
                end
                resolved_root = resolved_root or opts.root_dir(fname) or vim.loop.cwd()

                local config = extend_or_override({
                    cmd = full_cmd,
                    root_dir = resolved_root,
                    init_options = {
                        bundles = bundles,
                    },
                    -- enable CMP capabilities
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                }, opts.jdtls)

                -- Existing server will be reused if the root_dir matches.
                require("jdtls").start_or_attach(config)
                -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
            end

            -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
            -- depending on filetype, so this autocmd doesn't run for the first file.
            -- For that, we call directly below.
            vim.api.nvim_create_autocmd("FileType", {
                pattern = java_filetypes,
                callback = attach_jdtls,
            })

            -- Setup keymap and dap after the lsp is fully attached.
            -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
            -- https://neovim.io/doc/user/lsp.html#LspAttach
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "jdtls" then
                        local wk = require("which-key")
                        wk.register({
                            ["<leader>cx"] = { name = "+extract" },
                            ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
                            ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
                            ["gs"] = { require("jdtls").super_implementation, "Goto Super" },
                            ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
                            ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" },
                        }, { mode = "n", buffer = args.buf })
                        wk.register({
                            ["<leader>c"] = { name = "+code" },
                            ["<leader>cx"] = { name = "+extract" },
                            ["<leader>cxm"] = {
                                [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                                "Extract Method",
                            },
                            ["<leader>cxv"] = {
                                [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                                "Extract Variable",
                            },
                            ["<leader>cxc"] = {
                                [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                                "Extract Constant",
                            },
                        }, { mode = "v", buffer = args.buf })

                        if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
                            -- custom init for Java debugger
                            require("jdtls").setup_dap(opts.dap)
                            require("jdtls.dap").setup_dap_main_class_configs()

                            -- Java Test require Java debugger to work
                            if opts.test and mason_registry.is_installed("java-test") then
                                -- custom keymaps for Java test runner (not yet compatible with neotest)
                                wk.register({
                                    ["<leader>t"] = { name = "+test" },
                                    ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" },
                                    ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
                                    ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" },
                                }, { mode = "n", buffer = args.buf })
                            end
                        end

                        -- User can set additional keymaps in opts.on_attach
                        if opts.on_attach then
                            opts.on_attach(args)
                        end
                    end
                end,
            })

            -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
            attach_jdtls()
        end,
    },
}
