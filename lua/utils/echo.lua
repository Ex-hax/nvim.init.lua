local Echo = {}

function Echo.message(args)
    local icon = args.icon or "" -- Default to empty string if nil
    local msg = args.msg

    if msg then
        vim.cmd(string.format("echomsg '%s %s'", icon, msg))
    end
end

function Echo.message_with_icon(args)
    local icon = args.icon
    local msg = args.msg

    if msg and icon then
        vim.cmd(string.format("echomsg '%s %s'", icon, msg))
    elseif msg then
        vim.cmd(string.format("echomsg '💲 %s'", msg))
    elseif icon then
        return -- Nothing to do if only icon is provided
    end
end

return Echo
