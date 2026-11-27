-- ───────────────────────────────────────────────────────────
-- 🧹 Formatting (conform.nvim) & linting (nvim-lint)
--
--   SQL (incl. Jinja / Airflow templates) uses sqlfluff, with the settings of
--   the project the file belongs to: the nearest .sqlfluff / pyproject.toml /
--   setup.cfg / tox.ini (dialect, jinja templater + context, rules).
--
--   Ctrl-f        format the file (or the selected lines) — mapped in core/keymaps.lua
--                 (file types without a formatter here use their LSP, as before)
--   :Format       same as Ctrl-f
--   :FormatOnSave toggle formatting on save (off by default: sqlfluff is slow)
--   :Lint         re-run the linter now (also runs on open and on save)
--
--   A Jinja value sqlfluff can't render (e.g. {{ ds }}) needs a fake value in
--   the project's [tool.sqlfluff.templater.jinja] context, else the file is
--   reported as a templating error and not formatted.
-- ───────────────────────────────────────────────────────────

local sqlfluff_roots = { ".sqlfluff", "pep8.ini", "pyproject.toml", "setup.cfg", "tox.ini" }

-- Project folder of a buffer (where its sqlfluff settings are), or nil
local function sqlfluff_root(buf)
    return vim.fs.root(buf, sqlfluff_roots)
end

-- ── Formatter ─────────────────────────────────────────────
local M = {}
local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        sql = { "sqlfluff" },
    },
    formatters = {
        sqlfluff = {
            -- --stdin-filename: use the config files that apply to this file's folder
            args = { "fix", "--stdin-filename", "$FILENAME", "-" },
            -- 1 = fixed what it could, but some problems need a manual fix
            exit_codes = { 0, 1 },
            cwd = function(_, ctx) return sqlfluff_root(ctx.buf) end,
            require_cwd = false, -- no project config: sqlfluff's defaults (ansi dialect)
        },
    },
    default_format_opts = {
        timeout_ms = 15000, -- sqlfluff renders Jinja; big files can take seconds
        lsp_format = "fallback",
    },
    format_on_save = function(buf)
        if not vim.g.format_on_save then return end
        -- (the callback shows the same result message as Ctrl-f)
        local done = M.start_message(buf)
        return {}, done
    end,
    notify_on_error = false, -- our own messages below report errors
})

-- ── Status messages: in progress / success / no changes / failed ──
local function echo(icon, msg, hl, keep)
    local text = icon .. " " .. msg
    -- Fit on one line: a longer message would block with "Press ENTER"
    local room = math.max(vim.v.echospace - 1, 20)
    if vim.fn.strdisplaywidth(text) > room then
        text = vim.fn.strcharpart(text, 0, room - 1) .. "…"
    end
    vim.api.nvim_echo({ { text, hl } }, keep, {})
end

-- Name of what will format this buffer, e.g. "sqlfluff" or "LSP (lua_ls)"; nil if nothing
local function formatter_name(buf)
    local formatters, uses_lsp = conform.list_formatters_to_run(buf)
    local names = vim.tbl_map(function(f) return f.name end, formatters)
    if uses_lsp then
        local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })
        local lsp = vim.tbl_map(function(c) return c.name end, clients)
        table.insert(names, "LSP (" .. table.concat(lsp, ", ") .. ")")
    end
    if #names == 0 then return nil end
    return table.concat(names, " + ")
end

-- Shows "Formatting with X..." and returns a callback(err, did_edit) that shows
-- the result (or nil if this buffer has no formatter, after saying so)
function M.start_message(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    local name = formatter_name(buf)
    if not name then
        -- Configured but not usable (e.g. sqlfluff not installed) vs. none configured
        local broken
        for _, fname in ipairs(vim.iter(conform.list_formatters_for_buffer(buf)):flatten():totable()) do
            local info = conform.get_formatter_info(fname, buf)
            if not info.available then broken = info break end
        end
        if broken then
            echo("❌", broken.name .. " isn't available: " .. tostring(broken.available_msg)
                .. " (rebuild the image?)", "DiagnosticError", true)
        else
            echo("⚠️", "No formatter for this file type (" .. vim.bo[buf].filetype .. ")", "DiagnosticWarn", true)
        end
        return nil
    end
    local started = vim.uv.hrtime()
    echo("⏳", "Formatting with " .. name .. "...", "DiagnosticInfo", false)
    vim.cmd("redraw")
    return function(err, did_edit)
        vim.schedule(function()
            local secs = ("%.1fs"):format((vim.uv.hrtime() - started) / 1e9)
            if err then
                local first = tostring(err):gsub("^%s+", ""):match("[^\n]*")
                echo("❌", "Format failed (" .. name .. "): " .. first .. "  — :ConformInfo for details",
                    "DiagnosticError", true)
            elseif did_edit then
                echo("✅", "Formatted with " .. name .. " (" .. secs .. ")", "DiagnosticOk", true)
            elseif vim.bo[buf].filetype == "sql" then
                echo("ℹ️", "No changes by " .. name .. " (" .. secs .. "): already formatted,"
                    .. " or the Jinja couldn't render (see sqlfluff warnings)", "DiagnosticInfo", true)
            else
                echo("✅", "Already formatted (" .. name .. ", " .. secs .. ")", "DiagnosticOk", true)
            end
        end)
    end
end

-- Format the file (or the visual selection / given range) with status messages.
-- Used by Ctrl-f (core/keymaps.lua) and :Format.
function M.format(range)
    local done = M.start_message(0)
    if not done then return end
    conform.format({ async = true, range = range }, done)
end

vim.api.nvim_create_user_command("Format", function(opts)
    local range = nil
    if opts.range > 0 then
        range = { start = { opts.line1, 0 }, ["end"] = { opts.line2, 0 } }
    end
    M.format(range)
end, { range = true, desc = "Format file / selection" })

vim.api.nvim_create_user_command("FormatOnSave", function()
    vim.g.format_on_save = not vim.g.format_on_save
    vim.notify("Format on save: " .. (vim.g.format_on_save and "ON" or "OFF"))
end, { desc = "Toggle format on save" })

-- ── Linter ────────────────────────────────────────────────
local lint = require("lint")

lint.linters_by_ft = {
    sql = { "sqlfluff" },
}

-- Same idea as the formatter: tell sqlfluff which file it is, so the project's
-- settings (dialect, jinja context, rules) apply.
lint.linters.sqlfluff.args = {
    "lint", "--format=json",
    "--stdin-filename", function() return vim.api.nvim_buf_get_name(0) end,
    "-",
}

local function run_lint()
    local buf = vim.api.nvim_get_current_buf()
    if not lint.linters_by_ft[vim.bo[buf].filetype] then return end
    lint.try_lint(nil, { cwd = sqlfluff_root(buf) })
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("lint_on_save", { clear = true }),
    callback = run_lint,
})

vim.api.nvim_create_user_command("Lint", run_lint, { desc = "Run the linter" })

return M
