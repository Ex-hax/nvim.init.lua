-- ───────────────────────────────────────────────────────────
-- 📟 Terminal Integration
-- ───────────────────────────────────────────────────────────

local WindowsTerminal = {}

function WindowsTerminal.open()
    local cwd = vim.fn.getcwd()                          -- Get current working directory
    local cmd = string.format('silent !wt -d "%s"', cwd) -- Open Windows Terminal
    vim.cmd(cmd)
end

return WindowsTerminal
