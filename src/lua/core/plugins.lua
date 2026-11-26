require("lazy").setup({
    spec = {

        -- Custom dashboard
        { 'goolord/alpha-nvim' },

        -- 📂 File Explorer (configured in uia/widget/file_explorer.lua)
        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
                "nvim-tree/nvim-web-devicons",
            },
        },

        { "akinsho/bufferline.nvim",         dependencies = { "nvim-tree/nvim-web-devicons" } },

        -- 🔠 Icons (Load immediately as other plugins depend on them)
        { "nvim-tree/nvim-web-devicons",     lazy = false },

        -- 🎨 Syntax Highlighting (Lazy load when a buffer is read)
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",                              event = "BufReadPost" },

        -- Comment
        { "numToStr/Comment.nvim" },

        -- 📝 Auto-completion (Lazy load when inserting text)
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "L3MON4D3/LuaSnip",
            }
        },

        -- ⚡ LSP (Lazy load when opening a file with an LSP server)
        {
            "neovim/nvim-lspconfig",
            event = { "BufReadPre", "BufNewFile" }
        },
        {
            "williamboman/mason.nvim",
              
        },
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = { 
                "neovim/nvim-lspconfig",
                "williamboman/mason.nvim"
            },
        },

        -- 🐞 Debugging (Lazy load when starting a debugging session)
        { "mfussenegger/nvim-dap",         cmd = "DapToggleBreakpoint" },

        -- 🔄 Git Integration (Lazy load when opening a git file)
        { "lewis6991/gitsigns.nvim",       event = "BufRead" },

        -- 🔎 Fuzzy Finder (Lazy load when using Telescope)
        { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "Telescope" },

        -- 🖥️ Terminal (Lazy load when opening ToggleTerm)
        { "akinsho/toggleterm.nvim",       cmd = "ToggleTerm" },

        -- 🎨 Themes (Load Immediately)
        { "marko-cerovac/material.nvim",         lazy = false },
        { "folke/tokyonight.nvim",               lazy = false },

        -- 📊 Status Line (Lazy load when opening Neovim)
        { "nvim-lualine/lualine.nvim",           event = "VimEnter" },

        -- 📏 Indent Guides (Lazy load when opening a file)
        { "lukas-reineke/indent-blankline.nvim", event = "BufReadPost" },

        -- 🔍 hlslens (Lazy load when searching)
        { "kevinhwang91/nvim-hlslens",           event = "CmdlineEnter" },

        -- 📜 Scrollbar (Lazy load when opening a file)
        { "petertriho/nvim-scrollbar",           event = "BufReadPost" },

        -- 🤖 Claude Code (IDE-style integration: chat, diffs, context sync)
        { "folke/snacks.nvim",                   lazy = true },
        {
            "coder/claudecode.nvim",
            dependencies = { "folke/snacks.nvim" },
            config = true,
            cmd = {
                "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel",
                "ClaudeCodeAdd", "ClaudeCodeSend", "ClaudeCodeTreeAdd",
                "ClaudeCodeStatus", "ClaudeCodeStart", "ClaudeCodeStop",
                "ClaudeCodeOpen", "ClaudeCodeClose", "ClaudeCodeDiffAccept",
                "ClaudeCodeDiffDeny", "ClaudeCodeCloseAllDiffs",
            },
            keys = {
                { "<leader>ac", "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude" },
                { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",      desc = "Focus Claude" },
                { "<leader>as", "<cmd>ClaudeCodeSend<cr>",       mode = "v",             desc = "Send selection to Claude" },
                { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
                { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Reject Claude diff" },
            },
        },
    },
    install = { colorscheme = { "material" } }, -- You can change this to "tokyonight"
    checker = { enabled = true },
})
