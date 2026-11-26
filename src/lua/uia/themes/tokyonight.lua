-- ───────────────────────────────────────────────────────────
-- 🎨 UI & Theme Configuration
-- ───────────────────────────────────────────────────────────

require("tokyonight").setup({})

-- Lua
require('lualine').setup {
    options = {
        -- ... your lualine config
        theme = 'tokyonight'
        -- ... your lualine config
    },
    sections = {
        lualine_c = { { 'filename', path = 2 } }, -- `path = 1` shows relative path
    },
}

require("ibl").setup {
    -- indent = { char = "│" }, -- Change to '┆' or '¦' if you prefer
    scope = { enabled = true } -- Enables function-level guides
}

vim.cmd("colorscheme tokyonight")
