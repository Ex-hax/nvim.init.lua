-- ───────────────────────────────────────────────────────────
-- 🎨 General Settings
-- ───────────────────────────────────────────────────────────

local opt = vim.opt
local g = vim.g

opt.number = true             -- Show line numbers
opt.hlsearch = true           -- Highlight search results
opt.incsearch = true          -- Incremental search
opt.showtabline = 2           -- Always show the tab line
g.mapleader = " "             -- Set leader key
g.maplocalleader = "\\"       -- Set local leader key
-- g.material_style = "deep ocean" -- Set theme
