-- ───────────────────────────────────────────────────────────
-- 📌 Bootstrap lazy.nvim
-- ───────────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            { { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } },
            true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ───────────────────────────────────────────────────────────
-- 🔧 Core Configurations
-- ───────────────────────────────────────────────────────────
require("core.plugins") -- Plugin setup & lazy loading
require("core.options") -- General settings (line numbers, search, etc.)
require("core.keymaps") -- Keybindings
require("core.diagnostic")
require("core.commands.__init__")

-- ───────────────────────────────────────────────────────────
-- 🎨 UI & Appearance
-- ───────────────────────────────────────────────────────────
require("uia.themes.material") -- Default UI Theme
-- require("uia.themes.tokyonight")  -- Default UI Theme

-- ───────────────────────────────────────────────────────────
-- 🔧 Custom dashboard
-- ───────────────────────────────────────────────────────────
require("uia.alpha_dashboard")      -- Custom dashboard

-- ───────────────────────────────────────────────────────────
-- 🎨 Widget
-- ───────────────────────────────────────────────────────────
require("uia.widget._hlslens")      -- Enhanced search highlighting
require("uia.widget._scrollbar")    -- Scrollbar for visual navigation
require("uia.widget.file_explorer") -- NvimTree settings
require("uia.widget._tab")          -- File buffer tab

-- ───────────────────────────────────────────────────────────
-- 🤖 Language Features & Autocompletion
-- ───────────────────────────────────────────────────────────
require("lang._cmp")       -- Autocomplete setup
require("lang.treesitter") -- Syntax highlighting
require("lang.mason_lsp")  -- mason lsp
require("lang.lsp")        -- LSP (Uncomment if using)
require("lang.comment")    -- Comment/Uncomment code

-- ───────────────────────────────────────────────────────────
-- 🔎 Code Navigation & Search
-- ───────────────────────────────────────────────────────────
require("navsearch._telescope") -- Fuzzy finder

-- ───────────────────────────────────────────────────────────
-- 🛠️ Development Tools
-- ───────────────────────────────────────────────────────────
require("devtools.git")      -- Git integration
