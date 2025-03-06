-- ───────────────────────────────────────────────────────────
-- 💡 LSP Configuration (Language Server Protocol)
-- ───────────────────────────────────────────────────────────
local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
	-- cmd = { "docker", "exec", "-i", "nvim_lsp_server", "pyright", "--stdio" },
}) -- Python LSP
lspconfig.ruff.setup({})
lspconfig.jsonls.setup({
	-- cmd = { "docker", "exec", "-i", "nvim_lsp_server", "prettier", "--stdio" },
}) -- JSON LSP
lspconfig.html.setup({
	-- cmd = { "docker", "exec", "-i", "nvim_lsp_server", "vscode-langservers-extracted", "--stdio" },
})                       -- HTML LSP
lspconfig.yamlls.setup({ -- YAML LSP
	-- cmd = { "docker", "exec", "-i", "nvim_lsp_server", "yaml-language-server", "--stdio" },
})
lspconfig.sqlls.setup({}) -- SQL LSP
lspconfig.sqlfmt.setup({})
lspconfig.lua_ls.setup({})
