-- ───────────────────────────────────────────────────────────
-- 💡 Auto-completion (nvim-cmp)
-- ───────────────────────────────────────────────────────────

local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})
