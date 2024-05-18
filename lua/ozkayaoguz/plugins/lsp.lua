return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
            callback = function(event)
                local opts = { buffer = event.buf }
                local builtin = require("telescope.builtin")

                vim.keymap.set("n", "gd", function() builtin.lsp_definitions() end, opts)
                vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
                vim.keymap.set("n", "gr", function() builtin.lsp_references() end, opts)
                vim.keymap.set("n", "gI", function() builtin.lsp_implementations() end, opts)
                vim.keymap.set("n", "<leader>D", function() builtin.lsp_type_definitions() end, opts)
                vim.keymap.set("n", "<leader>ds", function() builtin.lsp_document_symbols() end, opts)
                vim.keymap.set("n", "<leader>df", function() vim.lsp.buf.format() end, opts)
                vim.keymap.set("n", "<leader>ws", function() builtin.lsp_dynamic_workspace_symbols() end, opts)
                vim.keymap.set("n", "<leader>wd", function() builtin.diagnostics() end, opts)
                vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("n", "<leader>a", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
            end,
        })

        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

        require("mason").setup({})
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls" },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = lsp_capabilities,
                    })
                end,
                lua_ls = function()
                    require("lspconfig").lua_ls.setup({
                        capabilities = lsp_capabilities,
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                diagnostics = {
                                    globals = { "vim" },
                                },
                                workspace = {
                                    library = {
                                        vim.env.VIMRUNTIME,
                                    },
                                },
                            },
                        },
                    })
                end,
            },
        })

        local cmp = require("cmp")
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        -- this is the function that loads the extra snippets to luasnip
        -- from rafamadriz/friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            sources = {
                { name = "path" },
                { name = "nvim_lsp" },
                { name = "luasnip", keyword_length = 2 },
                { name = "buffer",  keyword_length = 3 },
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
        })
    end,
}
