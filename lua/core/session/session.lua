local Echo = require("utils.echo")

local Session = {}
Session.__index = Session -- Enable OOP behavior

-- Constructor with user-defined or default session file
function Session:__init__(args)
    local args = args or {}
    local obj = setmetatable({}, self)
    obj.session_file = args.session_file or (vim.fn.expand("~") .. "/session.nvim") -- Default value
    obj.is_autoload = args.is_autoload or false
    return obj
end

-- Utility function for echo messages
local function echo_message(icon, msg)
    vim.cmd("echomsg '" .. icon .. " " .. msg .. "'")
end

-- Methods
function Session:save()
    vim.cmd("mksession! " .. vim.fn.fnameescape(self.session_file))
    Echo.message_with_icon({icon = '✅', msg = "Session has been saved to " .. self.session_file})
end

function Session:load()
    if self.is_autoload then
        if vim.fn.filereadable(self.session_file) == 1 then
            vim.cmd("source " .. vim.fn.fnameescape(self.session_file))
            Echo.message_with_icon({icon = '✅', msg = "Session loaded from " .. self.session_file})
        else
            Echo.message_with_icon({icon = '❌', msg = "Session file not found at " .. self.session_file})
        end
    end
end

function Session:delete()
    if vim.fn.filereadable(self.session_file) == 1 then
        os.remove(self.session_file)
        Echo.message_with_icon({icon = '✅', msg = self.session_file .. " has been deleted!"})
    else
        Echo.message_with_icon({icon = '❌', msg = "No session file to delete."})
    end
end

return Session
