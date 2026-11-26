-- ───────────────────────────────────────────────────────────
-- 🎨 UI & Theme Configuration
-- ───────────────────────────────────────────────────────────

local opt = vim.opt
local g = vim.g

-- ───────────────────────────────────────────────────────────
-- Set theme
-- ───────────────────────────────────────────────────────────
-- g.material_style = "palenight"

require('material').setup({

    contrast = {
        terminal = false,            -- Enable contrast for the built-in terminal
        sidebars = false,            -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
        floating_windows = false,    -- Enable contrast for floating windows
        cursor_line = true,          -- Enable darker background for the cursor line
        lsp_virtual_text = false,    -- Enable contrasted background for lsp virtual text
        non_current_windows = false, -- Enable contrasted background for non-current windows
        filetypes = {},              -- Specify which filetypes get the contrasted (darker) background
    },

    styles = { -- Give comments style such as bold, italic, underline etc.
        comments = { --[[ italic = true ]] },
        strings = { --[[ bold = true ]] },
        keywords = { --[[ underline = true ]] },
        functions = { --[[ bold = true, undercurl = true ]] },
        variables = {},
        operators = {},
        types = {},
    },

    plugins = { -- Uncomment the plugins that you use to highlight them
        -- Available plugins:
        -- "coc",
        -- "colorful-winsep",
        -- "dap",
        -- "dashboard",
        -- "eyeliner",
        -- "fidget",
        -- "flash",
        -- "gitsigns",
        -- "harpoon",
        -- "hop",
        -- "illuminate",
        -- "indent-blankline",
        -- "lspsaga",
        -- "mini",
        -- "neogit",
        -- "neotest",
        "neo-tree",
        -- "neorg",
        -- "noice",
        -- "nvim-cmp",
        -- "nvim-navic",
        -- "nvim-tree",
        -- "nvim-web-devicons",
        -- "rainbow-delimiters",
        -- "sneak",
        -- "telescope",
        -- "trouble",
        -- "which-key",
        -- "nvim-notify",
    },

    disable = {
        colored_cursor = false, -- Disable the colored cursor
        borders = false,        -- Disable borders between vertically split windows
        background = true,      -- Transparent: use the terminal's (iTerm2 blurred) background
        term_colors = false,    -- Prevent the theme from setting terminal colors
        eob_lines = false       -- Hide the end-of-buffer lines
    },

    high_visibility = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = false   -- Enable higher contrast text for darker style
    },

    -- lualine_style = "stealth", -- Lualine style ( can be 'stealth' or 'default' )

    async_loading = true, -- Load parts of the theme asynchronously for faster startup (turned on by default)

    custom_colors = function()
        local colors = require('material.colors')
        -- colors.editor.bg = "#252525"
        -- colors.main.purple = "#6b0000"
        colors.editor.line_numbers = "#a6f7eb"
        -- colors.lsp.error = "#SOME_COLOR"
    end,                    -- If you want to override the default colors, set this to a function

    custom_highlights = {}, -- Overwrite highlights with your own
})


require('lualine').setup({
    options = {
        theme = 'material-stealth',
    },
    sections = {
        lualine_c = { { 'filename', path = 2 } }, -- `path = 1` shows relative path
    },
})

require("ibl").setup {
    -- indent = { char = "│" }, -- Change to '┆' or '¦' if you prefer
    scope = { enabled = true } -- Enables function-level guides
}

-- Transparent background: also clear the side panels and gutters the theme
-- still paints (keeps each group's text colour, only removes its background).
local transparent_groups = {
    "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "LineNr", "FoldColumn",
    "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
}
local function clear_backgrounds()
    for _, group in ipairs(transparent_groups) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg, hl.ctermbg = nil, nil
        vim.api.nvim_set_hl(0, group, hl)
    end
end
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "material", callback = clear_backgrounds })

vim.cmd("colorscheme material")
