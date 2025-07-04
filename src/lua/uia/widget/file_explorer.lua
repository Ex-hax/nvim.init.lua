-- ───────────────────────────────────────────────────────────
-- 📂 File Explorer (nvim-tree)
-- ───────────────────────────────────────────────────────────

require("nvim-tree").setup({  
    git = {
      enable = true,
      ignore = false,
      timeout = 1500,
    },
  })

require("nvim-web-devicons").setup()
