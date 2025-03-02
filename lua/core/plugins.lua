require("lazy").setup({
  spec = {

      -- Custom dashboard
      {'goolord/alpha-nvim'},
      
      -- 📂 File Explorer (Lazy Load when opening NvimTree)
      { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }, cmd = "NvimTreeToggle" },

      { "akinsho/bufferline.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }},

      -- 🔠 Icons (Load immediately as other plugins depend on them)
      { "nvim-tree/nvim-web-devicons", lazy = false },

      -- 🎨 Syntax Highlighting (Lazy load when a buffer is read)
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = "BufReadPost" },

      -- 📝 Auto-completion (Lazy load when inserting text)
      { "hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "hrsh7th/cmp-cmdline",
          "L3MON4D3/LuaSnip",
      }},

      -- ⚡ LSP (Lazy load when opening a file with an LSP server)
      { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

      -- 🐞 Debugging (Lazy load when starting a debugging session)
      { "mfussenegger/nvim-dap", cmd = "DapToggleBreakpoint" },

      -- 🔄 Git Integration (Lazy load when opening a git file)
      { "lewis6991/gitsigns.nvim", event = "BufRead" },

      -- 🔎 Fuzzy Finder (Lazy load when using Telescope)
      { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "Telescope" },

      -- 🖥️ Terminal (Lazy load when opening ToggleTerm)
      { "akinsho/toggleterm.nvim", cmd = "ToggleTerm" },

      -- 📜 Syntax & Formatting (Load on specific file types)
      { "elzr/vim-json", ft = "json" },
      { "Glench/Vim-Jinja2-Syntax", ft = { "jinja", "html" } },
      { "MunifTanjim/prettier.nvim" },
      { "stephpy/vim-yaml", ft = "yaml" },
      { "cespare/vim-toml", ft = "toml" },
      { "plasticboy/vim-markdown", dependencies = { "godlygeek/tabular" }, ft = "markdown" },

      -- 🗄️ SQL Tools (Lazy load when opening SQL files)
      { "lifepillar/pgsql.vim", ft = "sql" },
      { "tpope/vim-dadbod", cmd = "DB" },
      { "kristijanhusak/vim-dadbod-ui", cmd = "DBUI" },

      -- 🎨 Themes (Load Immediately)
      { "marko-cerovac/material.nvim", lazy = false },
      { "folke/tokyonight.nvim", lazy = false },

      -- 📊 Status Line (Lazy load when opening Neovim)
      { "nvim-lualine/lualine.nvim", event = "VimEnter" },

      -- 📏 Indent Guides (Lazy load when opening a file)
      { "lukas-reineke/indent-blankline.nvim", event = "BufReadPost" },

      -- 🔍 hlslens (Lazy load when searching)
      { "kevinhwang91/nvim-hlslens", event = "CmdlineEnter" },

      -- 📜 Scrollbar (Lazy load when opening a file)
      { "petertriho/nvim-scrollbar", event = "BufReadPost" },
  },
  install = { colorscheme = { "material" }}, -- You can change this to "tokyonight"
  checker = { enabled = true },
})
