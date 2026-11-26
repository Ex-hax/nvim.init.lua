local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set custom highlight groups for Alpha Dashboard
vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#ad0707", bold = true }) -- Title/Header

-- Set header
dashboard.section.header.val = {
"                                                                                                                                                                                    ",
"╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗",
"║                                                                                                                                                                                  ║",
"║  ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗     ██████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗███╗   ██╗    ██████╗ ██████╗  ██████╗ ████████╗███████╗ ██████╗████████╗   ║",
"║  ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║████╗  ██║    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝   ║",
"║  ███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗      ██║     ██║   ██║██╔██╗ ██║   ██║   ███████║██║██╔██╗ ██║    ██████╔╝██████╔╝██║   ██║   ██║   █████╗  ██║        ██║      ║",
"║  ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝      ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║██║╚██╗██║    ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██╔══╝  ██║        ██║      ║",
"║  ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██║ ╚████║    ██║     ██║  ██║╚██████╔╝   ██║   ███████╗╚██████╗   ██║      ║",
"║  ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝   ╚═╝      ║",
"║                                                                                                                                                                                  ║",
"╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝",
"                                                                                                                                                                                    "
}

dashboard.section.header.opts.hl = "DashboardHeader"

-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("e", "📄 > New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("f", "🔭 > Find file", ":Telescope find_files<CR>"),
    dashboard.button("t", "📂 > Tree", ":Tree<CR>"),
    dashboard.button("r", "🎌 > Recent", ":Telescope oldfiles<CR>"),
    dashboard.button("c", "🤖 > Claude", ":Claude<CR>"),
    dashboard.button("s", "🛠️ > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
    dashboard.button("q", "🚪 > Quit NVIM", ":qa<CR>"),
}

-- Set footer
--   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
--   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
--   ```init.lua
--   return require('packer').startup(function()
--       use 'wbthomason/packer.nvim'
--       use {
--           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
--           requires = {'BlakeJC94/alpha-nvim-fortune'},
--           config = function() require("config.alpha") end
--       }
--   end)
--   ```
-- local fortune = require("alpha.fortune")
-- dashboard.section.footer.val = fortune()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])

-- ─── Header light sweep ───────────────────────────────────────────────
-- A bright, slightly slanted band slides left→right across the header,
-- then pauses. Runs only while the dashboard is visible.
vim.api.nvim_set_hl(0, "DashboardHeaderShineEdge", { fg = "#ff3b3b", bold = true })
vim.api.nvim_set_hl(0, "DashboardHeaderShineCore", { fg = "#ffd6d6", bold = true })

local sweep = {
    ns = vim.api.nvim_create_namespace("alpha_header_sweep"),
    interval = 30, -- ms per frame
    step = 3,      -- columns moved per frame
    core = 3,      -- width of the brightest part
    edge = 4,      -- width of the glow on each side
    slant = 2,     -- columns shifted per row (gives the diagonal look)
    pause = 50,    -- frames to wait between sweeps
    timer = nil,
}

-- Header rows in the alpha buffer (lines drawn with box/block characters)
local function header_rows(buf)
    local rows = {}
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if line:find("║", 1, true) or line:find("╔", 1, true) or line:find("╚", 1, true) then
            table.insert(rows, { row = i - 1, text = line, len = vim.fn.strchars(line) })
        end
    end
    return rows
end

-- Highlight characters [from, to) of a line (character indexes, all width 1)
local function hl_chars(buf, r, from, to, group)
    from, to = math.max(from, 0), math.min(to, r.len)
    if from >= to then return end
    -- pcall: alpha may redraw the buffer (e.g. on resize) between frames
    pcall(vim.api.nvim_buf_set_extmark, buf, sweep.ns, r.row, vim.fn.byteidx(r.text, from), {
        end_col = vim.fn.byteidx(r.text, to),
        hl_group = group,
        priority = 5000, -- must beat alpha's own header highlight (4096)
    })
end

-- Header geometry; recomputed every frame because alpha re-centers the
-- header when the window is resized (e.g. opening the file tree).
local function header_geometry(buf)
    local rows = header_rows(buf)
    local first, last = math.huge, 0
    for _, r in ipairs(rows) do
        first = math.min(first, (r.text:find("[^ ]") or 1) - 1)
        last = math.max(last, r.len)
    end
    return rows, first, last
end

local function stop_sweep()
    if sweep.timer then
        sweep.timer:stop()
        sweep.timer:close()
        sweep.timer = nil
    end
end

local function start_sweep()
    stop_sweep()
    local buf = vim.api.nvim_get_current_buf()
    if #header_rows(buf) == 0 then return end

    local band = sweep.core + 2 * sweep.edge
    local pos = 0

    sweep.timer = vim.uv.new_timer()
    sweep.timer:start(0, sweep.interval, vim.schedule_wrap(function()
        if not vim.api.nvim_buf_is_valid(buf) or vim.fn.bufwinid(buf) == -1 then
            return stop_sweep()
        end
        vim.api.nvim_buf_clear_namespace(buf, sweep.ns, 0, -1)
        local rows, first, last = header_geometry(buf)
        if #rows == 0 then return end
        local travel = (last - first) + band + #rows * sweep.slant
        if pos <= travel then
            for i, r in ipairs(rows) do
                local s = first + pos - band - (#rows - i) * sweep.slant
                hl_chars(buf, r, s, s + sweep.edge, "DashboardHeaderShineEdge")
                hl_chars(buf, r, s + sweep.edge, s + sweep.edge + sweep.core, "DashboardHeaderShineCore")
                hl_chars(buf, r, s + sweep.edge + sweep.core, s + band, "DashboardHeaderShineEdge")
            end
        end
        pos = pos + sweep.step
        if pos > travel + sweep.pause * sweep.step then pos = 0 end
    end))
end

vim.api.nvim_create_autocmd("User", { pattern = "AlphaReady", callback = start_sweep })
vim.api.nvim_create_autocmd("User", { pattern = "AlphaClosed", callback = stop_sweep })
