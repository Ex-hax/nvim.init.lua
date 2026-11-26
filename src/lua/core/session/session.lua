local Echo = require("utils.echo")

-- Named sessions stored as <session_dir>/<name>.vim
-- The last saved/loaded name is remembered in <session_dir>/.last for autoload.
local Session = {}
Session.__index = Session -- Enable OOP behavior

-- Constructor
--   session_dir: where session files live (default: stdpath("data")/sessions,
--                which is on the nvim_data volume in Docker)
--   is_autoload: reopen the last used session on startup
function Session:__init__(args)
    local args = args or {}
    local obj = setmetatable({}, self)
    obj.session_dir = args.session_dir or (vim.fn.stdpath("data") .. "/sessions")
    obj.is_autoload = args.is_autoload or false
    obj.current = nil -- name of the session in use
    vim.fn.mkdir(obj.session_dir, "p")
    return obj
end

-- ── helpers ────────────────────────────────────────────────────────────

-- Redraw first so the message replaces the input/select prompt
-- instead of being appended to it on the same line.
local function notify(icon, msg)
    vim.cmd("redraw")
    Echo.message_with_icon({ icon = icon, msg = msg })
end

-- File-tree windows (neo-tree) can't be restored by :mksession (they come
-- back as empty buffers), so the trees are closed while saving and reopened
-- by lines appended to the session file — one per tab that had a tree open.
local function tree_wins(tab)
    local wins = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then table.insert(wins, win) end
    end
    return wins
end

local function tree_is_open()
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if #tree_wins(tab) > 0 then return true end
    end
    return false
end

-- { { tabnr = 1, root = "/path" }, ... } for every tab with a tree open
local function open_trees()
    local ok, manager = pcall(require, "neo-tree.sources.manager")
    local list = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if #tree_wins(tab) > 0 then
            local state = ok and manager.get_state("filesystem", tab) or nil
            local tabnr = vim.api.nvim_tabpage_get_number(tab)
            table.insert(list, { tabnr = tabnr, root = (state and state.path) or vim.fn.getcwd(-1, tabnr) })
        end
    end
    return list
end

-- Close the tree in every tab. Done through neo-tree in each tab (closing the
-- window directly leaves neo-tree thinking it's still open, so it won't reopen).
local function tree_close()
    local cur_tab, cur_win = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_win()
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if #tree_wins(tab) > 0 then
            vim.api.nvim_set_current_tabpage(tab)
            pcall(vim.cmd, "Neotree close")
        end
    end
    vim.api.nvim_set_current_tabpage(cur_tab)
    if vim.api.nvim_win_is_valid(cur_win) then vim.api.nvim_set_current_win(cur_win) end
end

-- Reopen the trees (each in its tab, at its root) without moving the cursor
-- or leaving the current tab. trees = { { tabnr, root }, ... }
-- neo-tree draws asynchronously and ignores a second "show" started before the
-- previous one finished, so tabs are done one at a time: show, then check on
-- a short timer until that tree has appeared (max ~2s), then the next tab.
function Session.restore_trees(trees)
    local cur_tab, cur_win = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_win()
    local function finish()
        if vim.api.nvim_tabpage_is_valid(cur_tab) then vim.api.nvim_set_current_tabpage(cur_tab) end
        if vim.api.nvim_win_is_valid(cur_win) then vim.api.nvim_set_current_win(cur_win) end
    end
    local function step(i)
        local t = trees[i]
        if not t then return finish() end
        local tabnr, root = t[1], t[2]
        if tabnr > vim.fn.tabpagenr("$") or vim.fn.isdirectory(root) == 0 then return step(i + 1) end
        vim.cmd("tabnext " .. tabnr)
        local tab = vim.api.nvim_get_current_tabpage()
        pcall(function()
            require("neo-tree.command").execute({ action = "show", source = "filesystem", dir = root })
        end)
        local tries = 0
        local function check()
            tries = tries + 1
            if #tree_wins(tab) > 0 or tries >= 40 then return step(i + 1) end
            vim.defer_fn(check, 50)
        end
        vim.defer_fn(check, 50)
    end
    step(1)
end

local function trees_list(trees)
    local list = {}
    for _, t in ipairs(trees) do table.insert(list, { t.tabnr, t.root }) end
    return list
end

-- Line appended to a session file to reopen its trees when loaded
local function trees_restore_code(trees)
    return ("lua pcall(require('core.session.session').restore_trees, %s)")
        :format(vim.inspect(trees_list(trees), { newline = "", indent = "" }))
end

local function trees_restore(trees)
    if #trees > 0 then Session.restore_trees(trees_list(trees)) end
end

-- Leftover tree buffers from sessions (old NvimTree ones, or a neo-tree
-- buffer that came back without the plugin attached)
local function is_stale_tree_buf(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype
    return (name:match("NvimTree_%d+$") ~= nil) or (name:match("neo%-tree ") ~= nil and ft ~= "neo-tree")
end

-- Keep names filesystem- and echomsg-safe: letters, digits, _ - .
local function sanitize(name)
    name = vim.trim(name or "")
    return (name:gsub("[^%w_%-%.]", "_"))
end

function Session:path(name)
    return self.session_dir .. "/" .. name .. ".vim"
end

function Session:last_file()
    return self.session_dir .. "/.last"
end

function Session:remember(name)
    self.current = name
    vim.fn.writefile({ name }, self:last_file())
end

function Session:last()
    local f = self:last_file()
    if vim.fn.filereadable(f) == 1 then
        return vim.fn.readfile(f)[1]
    end
end

-- Sorted list of saved session names
function Session:list()
    local names = {}
    for _, file in ipairs(vim.fn.glob(self.session_dir .. "/*.vim", false, true)) do
        table.insert(names, vim.fn.fnamemodify(file, ":t:r"))
    end
    table.sort(names)
    return names
end

-- Run fn(name) with the given name, or ask for one with a picker
function Session:pick(name, prompt, fn)
    if name and name ~= "" then
        return fn(sanitize(name))
    end
    local names = self:list()
    if #names == 0 then
        return notify('❌', "No saved sessions.")
    end
    vim.ui.select(names, { prompt = prompt }, function(choice)
        if choice then fn(choice) end
    end)
end

-- ── methods ────────────────────────────────────────────────────────────

-- Save the current layout. Without a name, prompt (default: current session).
function Session:save(name)
    local function do_save(n)
        n = sanitize(n)
        if n == "" then
            return notify('❌', "Session name is empty, not saved.")
        end
        local file = self:path(n)

        -- Close the file trees while saving; remember each tab's tree root
        local trees = open_trees()
        if #trees > 0 then tree_close() end

        -- Don't store terminal buffers (e.g. the Claude panel) in the session
        local ssop = vim.o.sessionoptions
        vim.opt.sessionoptions:remove("terminal")
        local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(file))
        vim.o.sessionoptions = ssop

        if #trees > 0 then
            if ok then
                -- Reopen the trees (without focusing them) when the session is loaded
                vim.fn.writefile({ trees_restore_code(trees) }, file, "a")
            end
            trees_restore(trees)
        end

        if not ok then
            return notify('❌', "Failed to save session: " .. tostring(err):gsub("'", ""))
        end
        self:remember(n)
        notify('✅', "Session saved: " .. n)
    end

    if name and name ~= "" then
        return do_save(name)
    end
    vim.ui.input({ prompt = "Save session as: ", default = self.current or "default" }, function(input)
        if input then do_save(input) end
    end)
end

-- Switch to a saved session. Without a name, pick from the list.
function Session:load(name)
    self:pick(name, "Load session:", function(n)
        local file = self:path(n)
        if vim.fn.filereadable(file) == 0 then
            return notify('❌', "No session named " .. n)
        end
        for _, buf in ipairs(vim.fn.getbufinfo({ bufmodified = 1 })) do
            if buf.listed == 1 then
                return notify('❌', "Unsaved changes in " .. vim.fn.fnamemodify(buf.name, ":t") .. ", save them first.")
            end
        end
        if tree_is_open() then tree_close() end
        vim.cmd("silent! %bwipeout") -- start clean so sessions don't mix
        vim.cmd("silent! source " .. vim.fn.fnameescape(file))
        -- Older sessions may contain an empty tree buffer (e.g. "NvimTree_1"); remove it
        vim.schedule(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                -- (closing one window can close others, so re-check validity)
                if vim.api.nvim_win_is_valid(win) and is_stale_tree_buf(vim.api.nvim_win_get_buf(win)) then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if is_stale_tree_buf(buf) then
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end
            end
        end)
        self:remember(n)
        notify('✅', "Session loaded: " .. n)
    end)
end

-- Called on startup: reopen the last used session, if any
function Session:autoload()
    if not self.is_autoload then return end
    -- `nvim file.py` opens that file instead of the session (`nvim .` still autoloads)
    for _, arg in ipairs(vim.fn.argv()) do
        if vim.fn.isdirectory(arg) == 0 then return end
    end
    local n = self:last()
    if n and vim.fn.filereadable(self:path(n)) == 1 then
        self:load(n)
    end
end

-- Delete a saved session. Without a name, pick from the list.
function Session:delete(name)
    self:pick(name, "Delete session:", function(n)
        local file = self:path(n)
        if vim.fn.filereadable(file) == 0 then
            return notify('❌', "No session named " .. n)
        end
        os.remove(file)
        if self:last() == n then os.remove(self:last_file()) end
        if self.current == n then self.current = nil end
        notify('✅', "Session deleted: " .. n)
    end)
end

return Session
