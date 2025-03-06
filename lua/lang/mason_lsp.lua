require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls", "tsserver", "pyright", "yamlls", "sqlls", "sqlfmt", "jsonls", "ruff"
	}, -- Install LSP servers automatically
})
