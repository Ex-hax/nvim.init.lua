-- ───────────────────────────────────────────────────────────
-- 🎨 General Settings default base on nvim and plugins
-- ───────────────────────────────────────────────────────────

local opt = vim.opt
local g = vim.g
local o = vim.o

opt.termguicolors = true -- Set Neovim to use the full screen size
o.linespace = 0          -- Set Neovim to use the full screen size
opt.number = true        -- Show line numbers
opt.hlsearch = true      -- Highlight search results
opt.incsearch = true     -- Incremental search
opt.showtabline = 2      -- Always show the tab line
opt.expandtab = true     -- Use spaces instead of tabs
opt.tabstop = 4          -- Set tab width to 4 spaces
opt.shiftwidth = 4       -- Indentation width
opt.softtabstop = 4      -- Backspace treats 4 spaces as a tab
g.mapleader = " "        -- Set leader key
g.maplocalleader = "\\"  -- Set local leader key

-- ───────────────────────────────────────────────────────────
-- 🎨 General Settings custom plugins
-- ───────────────────────────────────────────────────────────
