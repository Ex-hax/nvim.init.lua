-- ───────────────────────────────────────────────────────────
-- 📂 File Explorer (nvim-tree)
-- ───────────────────────────────────────────────────────────

require("nvim-tree").setup({  
    git = {
      enable = true,
      ignore = false,
      timeout = 500,
    },
  })

require("nvim-web-devicons").setup()
