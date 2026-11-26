require("bufferline").setup({
    options = {
      mode = "buffers", -- Show open files as tabs
      separator_style = "slant",
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
    },
})
