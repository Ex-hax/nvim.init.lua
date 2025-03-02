-- ───────────────────────────────────────────────────────────
-- 💡 LSP Configuration (Language Server Protocol)
-- ───────────────────────────────────────────────────────────
local lspconfig = require("lspconfig")

lspconfig.pyright.setup({})   -- Python LSP
lspconfig.jsonls.setup({})    -- JSON LSP
lspconfig.html.setup({})      -- HTML LSP
lspconfig.yamlls.setup({})    -- YAML LSP
lspconfig.sqlls.setup({})     -- SQL LSP
