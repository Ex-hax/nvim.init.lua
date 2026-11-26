-- ───────────────────────────────────────────────────────────
-- 📂 File Explorer (neo-tree)
--   :Tree            toggle the sidebar
--   :Treeo [path]    open the sidebar at a folder
--   ?                (inside the tree) show all keys
--
--   File operations (inside the tree):
--     a  new file   (end with "/" for a folder, e.g. "src/utils/")
--     A  new folder
--     r  rename            b  rename basename (keep extension)
--     m  move              c  copy
--     d  delete            (select several lines in visual mode first to delete many)
--     x  cut   y  copy   p  paste   (also work on a visual selection)
--     H  show/hide hidden files     /  fuzzy filter     P  preview
--     <  >  switch tabs: Files / Git / Buffers
--
--   Changing the tree's root folder:
--     Backspace   go up to the parent folder
--     .           go into the folder under the cursor (make it the root)
-- ───────────────────────────────────────────────────────────

require("nvim-web-devicons").setup()

require("neo-tree").setup({
    close_if_last_window = true, -- quit Neovim instead of leaving only the tree open
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,

    -- Tabs at the top of the sidebar: Files / Git / Buffers
    source_selector = {
        winbar = true,
        content_layout = "center",
        sources = {
            { source = "filesystem", display_name = " 󰉓 Files " },
            { source = "git_status", display_name = " 󰊢 Git " },
            { source = "buffers", display_name = " 󰈚 Buffers " },
        },
    },

    default_component_configs = {
        indent = {
            with_expanders = true,
            expander_collapsed = "",
            expander_expanded = "",
        },
        modified = { symbol = "●" },
        git_status = {
            symbols = {
                added = "✚",
                modified = "",
                deleted = "✖",
                renamed = "󰁕",
                untracked = "",
                ignored = "",
                unstaged = "󰄱",
                staged = "",
                conflict = "",
            },
        },
    },

    window = {
        position = "left",
        width = 35,
        mappings = {
            -- Space is the leader key; don't let the tree swallow it
            ["<space>"] = "none",
            ["l"] = "open",
            ["h"] = "close_node",
            ["P"] = { "toggle_preview", config = { use_float = true } },
        },
    },

    filesystem = {
        -- Same as the old nvim-tree setup: show git-ignored and hidden files
        filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            never_show = { ".DS_Store" },
        },
        follow_current_file = { enabled = true }, -- highlight the file you're editing
        use_libuv_file_watcher = true,            -- refresh automatically when files change on disk
        hijack_netrw_behavior = "open_default",   -- `nvim .` opens the tree
    },
})
