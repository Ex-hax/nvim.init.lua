-- ───────────────────────────────────────────────────────────
-- ⌨️ Keybindings
-- ───────────────────────────────────────────────────────────

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- HTML (Jinja2 format)
keymap('n', '<C-f>', vim.lsp.buf.format, opts)

-- Cancel highlight
keymap("n", "<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- Select all text in Normal mode
keymap('n', '<C-a>', 'ggVG', opts)
-- Copy to system clipboard in Visual mode
keymap('v', '<C-c>', '"+y', opts)

-- Copy to system clipboard in Visual mode
keymap('v', '<C-c>', '"+y', opts)

-- Paste in Normal mode
keymap('n', '<C-v>', '"+p', opts)

-- Paste in Insert mode
keymap('i', '<C-v>', '<C-r>+', opts)

-- Paste and replace selection in Visual mode
keymap('v', '<C-v>', '"+p', opts)

-- hlslens
local function hlslens_start()
    require('hlslens').start()
end

keymap('n', '<C-g>', function()
    vim.cmd('normal! N')
    hlslens_start()
end, opts)

keymap('n', '<C-t>', function()
    vim.cmd('normal! n')
    hlslens_start()
end, opts)

keymap('i', '<C-g>', function()
    vim.cmd('normal! N')
    hlslens_start()
end, opts)

keymap('i', '<C-t>', function()
    vim.cmd('normal! n')
    hlslens_start()
end, opts)

keymap('n', '*', function()
    vim.cmd('normal! *')
    hlslens_start()
end, opts)

keymap('n', '#', function()
    vim.cmd('normal! #')
    hlslens_start()
end, opts)

keymap('n', 'g*', function()
    vim.cmd('normal! g*')
    hlslens_start()
end, opts)

keymap('n', 'g#', function()
    vim.cmd('normal! g#')
    hlslens_start()
end, opts)

-- Comment
keymap("n", "<C-_>", function()
    require('Comment.api').toggle.linewise.current()
end, opts)

keymap("v", "<C-_>", function()
    require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, opts)
