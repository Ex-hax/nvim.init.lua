-- ───────────────────────────────────────────────────────────
-- ⌨️ Keybindings
-- ───────────────────────────────────────────────────────────

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- JSON Formatter (Ctrl + J)
keymap("n", "<A-j>", ":%!prettier --parser json<CR>", opts)

-- HTML (Jinja2 format)
keymap('n', '<A-h>', ':lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })

-- Cancel highlight
keymap("n", "<Esc>", ":nohlsearch<CR>", opts)

-- hlslens
keymap('n', '<C-g>', [[<Cmd>normal! N<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("n", "<C-t>", [[<Cmd>normal! n<CR><Cmd>lua require('hlslens').start()<CR>]], opts)

keymap('i', '<C-g>', [[<Cmd>normal! N<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("i", "<C-t>", [[<Cmd>normal! n<CR><Cmd>lua require('hlslens').start()<CR>]], opts)

keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

