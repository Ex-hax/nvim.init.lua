-- ───────────────────────────────────────────────────────────
-- ⌨️ Keybindings
-- ───────────────────────────────────────────────────────────
local Echo = require("utils.echo")

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Format the file (or the selected lines) — see lang/format.lua
--   SQL (incl. Jinja/Airflow) → sqlfluff; other files → their LSP, as before
keymap({ 'n', 'x' }, '<C-f>', function()
    require("lang.format").format() -- shows in progress / success / failed
end, opts)

-- Cancel highlight
keymap("n", "<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- Select all text in Normal mode
keymap('n', '<C-a>', 'ggVG', opts)

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
keymap("n", "<C-/>", function()
    require('Comment.api').toggle.linewise.current()
end, opts)

keymap("x", "<C-/>", function()
    -- Leave visual mode first so the '< and '> marks point at the current
    -- selection; otherwise Comment.nvim toggles the previous selection's range.
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, opts)

keymap("n", "T", function()
    local WindowsTerminal = require("devtools.terminal")
    Echo.message_with_icon({ msg = 'Opening WindowsTerminal ...' })
    local success, err = pcall(WindowsTerminal.open)
    if not success then
        Echo.message_with_icon({ icon = '❌', msg = 'Failed to open Windows Terminal: ' .. err })
    else
        Echo.message_with_icon({ icon = '✅', msg = 'Opened WindowsTerminal success!' })
    end
end, opts)
