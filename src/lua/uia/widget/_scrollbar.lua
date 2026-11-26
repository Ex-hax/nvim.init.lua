-- nvim-scrollbar v2 config (see docs/migration.md in the plugin repo)
require("scrollbar").setup({
    set_highlights = true,

    -- A list replaces the plugin defaults (same as v1's excluded_* options)
    exclude = {
        buftypes = {
            "terminal",
        },
        filetypes = {
            "dropbar_menu",
            "dropbar_menu_fzf",
            "DressingInput",
            "cmp_docs",
            "cmp_menu",
            "noice",
            "prompt",
            "TelescopePrompt",
            "neo-tree",
            "neo-tree-popup",
        },
    },

    -- v1 "handlers"; search no longer needs hlslens
    providers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true, -- Requires gitsigns
        search = true,
        ale = false,     -- Requires ALE
    },

    marks = {
        Cursor = { text = "•", priority = 0, highlight = "Normal" },
        Search = { text = { "-", "=" }, priority = 1, highlight = "Search" },
        Error = { text = { "-", "=" }, priority = 2, highlight = "DiagnosticVirtualTextError" },
        Warn = { text = { "-", "=" }, priority = 3, highlight = "DiagnosticVirtualTextWarn" },
        Info = { text = { "-", "=" }, priority = 4, highlight = "DiagnosticVirtualTextInfo" },
        Hint = { text = { "-", "=" }, priority = 5, highlight = "DiagnosticVirtualTextHint" },
        Misc = { text = { "-", "=" }, priority = 6, highlight = "Normal" },
        GitAdd = { text = "┆", priority = 7, highlight = "GitSignsAdd" },
        GitChange = { text = "┆", priority = 7, highlight = "GitSignsChange" },
        GitDelete = { text = "▁", priority = 7, highlight = "GitSignsDelete" },
    },

    scrollbar = {
        show = true,
        visibility = "all",        -- v1: show_in_active_only = false
        unit = "screenline",       -- v1: folds = 1000 (account for closed folds)
        max_lines = false,         -- disables if no. of lines in buffer exceeds this
        hide_if_all_visible = false, -- Hides everything if all lines are visible
        throttle_ms = 100,
        thumb = {                  -- v1: handle
            text = " ",
            blend = 0,             -- 0 = fully opaque, 100 = fully transparent
            -- Fixed grey (Material blue-grey). Was "CursorColumn", which has no
            -- colour with the transparent theme, so the thumb fell back to white.
            highlight = { bg = "#546E7A" },
            hide_if_all_visible = true, -- Hides thumb if all lines are visible
        },
    },
})
