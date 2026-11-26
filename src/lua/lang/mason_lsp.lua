require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls", "pyright", "yamlls", "sqlls", "jsonls", "ruff", "html", "vimls"
	}, -- Install LSP servers automatically  --remove sqlfmt
})
