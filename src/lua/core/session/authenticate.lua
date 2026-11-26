local Echo = require("utils.echo")

local authenticate = {}

-- Users and password hashes live in user.lua, which is kept out of git.
-- (Template: user.example.lua)
local function load_users()
    package.loaded["core.session.user"] = nil -- re-read after edits (e.g. :Lock)
    local ok, users = pcall(require, "core.session.user")
    if ok and type(users) == "table" and next(users) ~= nil then return users end
    return nil
end

-- Login box (non-blocking)
--   A centered floating window asks for the username, then the password
--   (shown as ****). Keys are captured with vim.on_key instead of input(),
--   which would freeze Neovim — and with it the dashboard animation — while
--   waiting. While the box is open every other key is ignored, so it still
--   locks the editor (:Lock).
--     Enter        next field / submit
--     Backspace    delete a character     Ctrl-U  clear the field
--     Esc          give up (same as a wrong password: Neovim exits)
--   on_success()  called after a correct login (e.g. to load the session)
local active = false

function authenticate.login(on_success)
    if active then return end

    local valid_users = load_users()
    if not valid_users then
        -- No user.lua (e.g. a fresh clone): don't lock you out of the editor
        vim.notify("Login is off: no users in lua/core/session/user.lua (see user.example.lua)",
            vim.log.levels.WARN)
        if on_success then on_success() end
        return
    end
    active = true

    local ns = vim.api.nvim_create_namespace("authenticate_login")
    local KEY = {
        cr = vim.keycode("<CR>"), nl = vim.keycode("<NL>"),
        bs = vim.keycode("<BS>"), ch = vim.keycode("<C-h>"), del = "\127",
        esc = vim.keycode("<Esc>"), cu = vim.keycode("<C-u>"),
    }

    local username, password = "", ""
    local stage = "username" -- username -> password -> done

    -- Floating window in the middle of the screen
    local width = 40
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = 3,
        row = math.floor((vim.o.lines - 5) / 2),
        col = math.floor((vim.o.columns - width - 2) / 2),
        style = "minimal",
        border = "rounded",
        title = " Login ",
        title_pos = "center",
        zindex = 250,
        focusable = false,
    })
    vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"

    local function render(status)
        if not vim.api.nvim_buf_is_valid(buf) then return end
        local cursor = "▏"
        local lines = {
            " 👾 username ~ " .. username .. (stage == "username" and cursor or ""),
            stage ~= "username" and (" 🔒 password ~ " .. string.rep("*", vim.fn.strchars(password))
                .. (stage == "password" and cursor or "")) or "",
            status and (" " .. status) or "",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    local function close()
        vim.on_key(nil, ns)
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        active = false
    end

    local function finish()
        local ok = valid_users[username] ~= nil and valid_users[username] == vim.fn.sha256(password)
        if ok then
            render("✅ Access Granted!")
            vim.defer_fn(function()
                close()
                vim.cmd("redraw")
                Echo.message_with_icon({ icon = '✅', msg = 'Access Granted!' })
                if on_success then on_success() end
            end, 700)
        else
            render("❌ Access Denied! Exiting...")
            vim.defer_fn(function() vim.cmd("qall!") end, 1300)
        end
    end

    render()

    -- Capture every key while the box is open; returning "" discards it
    vim.on_key(function(_, typed)
        if stage == "done" or typed == nil or typed == "" then return "" end
        local changed = true
        if typed == KEY.cr or typed == KEY.nl then
            if stage == "username" then
                stage = "password"
            else
                stage = "done"
                vim.schedule(finish)
                return ""
            end
        elseif typed == KEY.esc then
            stage = "done"
            username, password = "", "" -- counts as a failed login
            vim.schedule(finish)
            return ""
        elseif typed == KEY.bs or typed == KEY.ch or typed == KEY.del then
            if stage == "username" then
                username = vim.fn.strcharpart(username, 0, vim.fn.strchars(username) - 1)
            else
                password = vim.fn.strcharpart(password, 0, vim.fn.strchars(password) - 1)
            end
        elseif typed == KEY.cu then
            if stage == "username" then username = "" else password = "" end
        elseif typed:byte(1) >= 32 and typed:byte(1) ~= 0x80 and typed:byte(1) ~= 127 then
            -- printable text (one character, or several when pasted)
            if stage == "username" then username = username .. typed else password = password .. typed end
        else
            changed = false -- other special keys: ignore
        end
        if changed then vim.schedule(render) end
        return ""
    end, ns)
end

return authenticate
