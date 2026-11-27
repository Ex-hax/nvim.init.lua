local api = vim.api
local authenticate = _G.authenticate
local session = _G.session

-- ── Smart :q ──────────────────────────────────────────────
--   :q / :q!    close the current file and show another open file in the
--               same window; if it was the last file, show the dashboard.
--               (:q on the dashboard quits Neovim.)
--               With 2+ split windows, :q closes the split (normal Vim).
--   :wq / :x    save, then the same as :q
local function is_file_buf(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

local function smart_quit(bang)
    local bang_s = bang and "!" or ""
    local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    -- Special windows (tree, help, terminal, dashboard, floats): plain :quit
    if not is_file_buf(buf) or vim.api.nvim_win_get_config(win).relative ~= "" then
        return vim.cmd("quit" .. bang_s)
    end

    -- Several file windows in this tab (splits): close just this split
    local file_wins = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(w).relative == "" and is_file_buf(vim.api.nvim_win_get_buf(w)) then
            file_wins = file_wins + 1
        end
    end
    if file_wins > 1 then
        return vim.cmd("quit" .. bang_s)
    end

    -- Another file to switch to? (prefer the previous one, #)
    local alt = vim.fn.bufnr("#")
    if alt == buf or not is_file_buf(alt) then
        alt = nil
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if b ~= buf and is_file_buf(b) then alt = b break end
        end
    end

    if vim.bo[buf].modified and not bang then
        return vim.api.nvim_echo({ { "E37: No write since last change (add ! to override)", "ErrorMsg" } }, true, {})
    end

    if alt then
        vim.api.nvim_win_set_buf(win, alt)
    else
        -- Last file: show the dashboard in this window instead of quitting.
        -- (:q on the dashboard, or its "Quit NVIM" button, then exits.)
        vim.cmd("Alpha")
    end
    pcall(vim.cmd, "bdelete! " .. buf)
end

api.nvim_create_user_command("SmartQuit", function(opts) smart_quit(opts.bang) end, { bang = true })
api.nvim_create_user_command("SmartWriteQuit", function(opts)
    vim.cmd("write" .. (opts.bang and "!" or ""))
    smart_quit(false)
end, { bang = true })
api.nvim_create_user_command("SmartExit", function()
    if vim.bo.modified then vim.cmd("write") end
    smart_quit(false)
end, {})

-- When Enter is pressed on exactly one of these commands, run the smart version.
-- (A cmdline abbreviation can't catch "q!", so Enter is intercepted instead.)
local smart_cmds = {
    ["q"] = "SmartQuit", ["q!"] = "SmartQuit!",
    ["wq"] = "SmartWriteQuit", ["wq!"] = "SmartWriteQuit!",
    ["x"] = "SmartExit",
}
vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() == ":" then
        local smart = smart_cmds[vim.trim(vim.fn.getcmdline())]
        if smart then vim.fn.setcmdline(smart) end
    end
    return "<CR>"
end, { expr = true, desc = "Smart :q / :wq / :x" })

-- Custom command to open Explorer tree
--   Pins the current folder to this tab first (:tcd), so a :cd in another
--   tab doesn't move this tab's tree (same behaviour as :Treeo).
api.nvim_create_user_command("Tree", function()
    vim.cmd("tcd " .. vim.fn.fnameescape(vim.fn.getcwd()))
    vim.cmd("Neotree toggle")
end, {})

-- :Lock  lock the editor behind the login box
--   Only exists when the login is on (lua/core/session/user.lua has users).
if authenticate.enabled() then
    api.nvim_create_user_command("Lock", function()
        authenticate.login()
    end, {})
end

-- Named sessions
--   :Saves [name]   save (prompts for a name if omitted)
--   :Loads [name]   switch to a session (picker if omitted)
--   :Dels  [name]   delete a session (picker if omitted)
local function complete_sessions(arg_lead)
    return vim.tbl_filter(function(n)
        return n:find(arg_lead, 1, true) == 1
    end, session:list())
end

api.nvim_create_user_command("Saves", function(opts)
    session:save(opts.args)
end, { nargs = "?", complete = complete_sessions })

api.nvim_create_user_command("Loads", function(opts)
    session:load(opts.args)
end, { nargs = "?", complete = complete_sessions })

api.nvim_create_user_command("Dels", function(opts)
    session:delete(opts.args)
end, { nargs = "?", complete = complete_sessions })

api.nvim_create_user_command("Treeo", function(opts)
    local path = opts.args ~= "" and opts.args or vim.fn.getcwd()
    require("neo-tree.command").execute({ action = "focus", source = "filesystem", dir = path })
end, { nargs = "?", complete = "dir" })

-- Claude Code (claudecode.nvim)
--   :Claude              toggle the Claude panel
--   :Claude --resume     pick a past session of this folder (any claude option works)
--   :'<,'>Claude         send the selected lines to Claude
--   :ClaudeSessions      list saved sessions of ALL projects, newest first;
--                        pick one to cd (this tab) into its project and resume it
--   :ClaudeSessionsDel   pick a saved session and delete it (asks to confirm)
api.nvim_create_user_command("Claude", function(opts)
    if opts.range > 0 then
        vim.cmd(("%d,%dClaudeCodeSend"):format(opts.line1, opts.line2))
    else
        vim.cmd("ClaudeCode " .. opts.args)
    end
end, { range = true, nargs = "*" })

-- Read a session file's folder and first typed prompt (stops early; files can be big)
local function claude_session_info(file)
    local ok, lines = pcall(io.lines, file)
    if not ok then return nil end
    local n = 0
    for line in lines do
        n = n + 1
        if n > 300 then break end
        if line:find('"type":"user"', 1, true) then
            local ok_json, entry = pcall(vim.json.decode, line)
            local content = ok_json and entry.message and entry.message.content
            if type(content) == "string" and entry.cwd then
                return { cwd = entry.cwd, prompt = content:gsub("%s+", " ") }
            end
        end
    end
end

local function claude_dir()
    return vim.env.CLAUDE_CONFIG_DIR or (vim.env.HOME .. "/.claude")
end

-- Pick a saved session (all projects, newest first) and call fn(session)
local function pick_claude_session(prompt, fn)
    local dir = claude_dir() .. "/projects"
    local items = {}
    for _, file in ipairs(vim.fn.glob(dir .. "/*/*.jsonl", false, true)) do
        local info = claude_session_info(file)
        if info then
            info.file = file
            info.id = vim.fn.fnamemodify(file, ":t:r")
            info.mtime = vim.fn.getftime(file)
            table.insert(items, info)
        end
    end
    if #items == 0 then
        return vim.notify("No saved Claude sessions in " .. dir, vim.log.levels.INFO)
    end
    table.sort(items, function(a, b) return a.mtime > b.mtime end)

    vim.ui.select(items, {
        prompt = prompt,
        format_item = function(it)
            local text = #it.prompt > 60 and (it.prompt:sub(1, 57) .. "...") or it.prompt
            return ("%s  %-28s  %s"):format(os.date("%Y-%m-%d %H:%M", it.mtime),
                vim.fn.fnamemodify(it.cwd, ":t"), text)
        end,
    }, function(choice)
        if choice then fn(choice) end
    end)
end

-- :ClaudeSessionsDel   pick a session and delete it (asks to confirm)
api.nvim_create_user_command("ClaudeSessionsDel", function()
    pick_claude_session("Delete Claude session:", function(s)
        local label = vim.fn.fnamemodify(s.cwd, ":t") .. ": " .. s.prompt:sub(1, 50)
        if vim.fn.confirm("Delete Claude session?\n" .. label, "&Yes\n&No", 2) ~= 1 then return end
        -- The conversation file, plus this session's own folders (if any)
        local paths = {
            s.file,
            vim.fn.fnamemodify(s.file, ":r"),               -- projects/<dir>/<id>/ (subagents etc.)
            claude_dir() .. "/file-history/" .. s.id,       -- file snapshots for /rewind
            claude_dir() .. "/session-env/" .. s.id,
            claude_dir() .. "/todos/" .. s.id .. "-agent-" .. s.id .. ".json",
        }
        for _, p in ipairs(paths) do
            if vim.fn.isdirectory(p) == 1 then
                vim.fn.delete(p, "rf")
            elseif vim.fn.filereadable(p) == 1 then
                vim.fn.delete(p)
            end
        end
        vim.cmd("redraw")
        vim.notify("Deleted Claude session: " .. label)
    end)
end, {})

api.nvim_create_user_command("ClaudeSessions", function()
    pick_claude_session("Claude sessions (all projects):", function(choice)
        if vim.fn.isdirectory(choice.cwd) == 0 then
            return vim.notify("Project folder no longer exists: " .. choice.cwd, vim.log.levels.WARN)
        end
        -- Only one Claude panel runs at a time: close the current one first
        local term = require("claudecode.terminal")
        if term.get_active_terminal_bufnr() then term.close() end
        vim.cmd("tcd " .. vim.fn.fnameescape(choice.cwd))
        term.open({}, "--resume " .. choice.id)
    end)
end, {})
api.nvim_create_user_command("ClaudeAccept", "ClaudeCodeDiffAccept", {})
api.nvim_create_user_command("ClaudeReject", "ClaudeCodeDiffDeny", {})
