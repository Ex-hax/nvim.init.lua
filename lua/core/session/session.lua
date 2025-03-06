local session = {}

function session.save()
    vim.cmd('mksession! ~/session.nvim')
    vim.cmd("echomsg '✅ Session has been saved.'")
end

function session.load()
    local session_file = vim.fn.expand("~") .. "\\session.nvim"
    if vim.fn.filereadable(session_file) == 1 then
        vim.cmd("source " .. vim.fn.fnameescape(vim.fn.expand("~") .. "\\session.nvim"))
        vim.cmd("echomsg '✅ Session loaded from " .. session_file .. "'")
    else
        vim.cmd("echomsg '❌ session.nvim not found at " .. session_file .. "!'")
    end
end

-- function session.delete()
--     local session_file = vim.fn.expand("~") .. "\\session.nvim"
--     if vim.fn.filereadable(session_file) == 1 then
-- 	    vim.cmd("silent !rm " .. vim.fn.fnameescape(vim.fn.expand("~") .. "\\session.nvim"))
--         vim.cmd("echomsg '✅ " .. session_file .. " has been deleted!'")
--     end
-- end

return session
