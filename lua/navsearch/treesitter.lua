-- ───────────────────────────────────────────────────────────
-- 📜 Treesitter (Better Syntax Highlighting)
-- ───────────────────────────────────────────────────────────

require("nvim-treesitter.configs").setup({
    ensure_installed = { "python", "json", "yaml", "toml", "markdown", "sql" },
    highlight = { enable = true },
  })
