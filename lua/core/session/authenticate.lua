local authenticate = {}

function authenticate.login()
    local valid_users = {
        lee = "4e6945a787f736473c7a65f7e360a37a494022dcbd2d5366c97ef5100dffbb66",
    }

    -- Function to create a floating input window in the center
    local function password_prompt()
        -- local buf = vim.api.nvim_create_buf(false, true)  -- Create scratch buffer
        -- local width, height = 50, 5
        -- local opts = {
        --     relative = "editor",
        --     width = width,
        --     height = height,
        --     col = (vim.o.columns - width) / 2,
        --     row = (vim.o.lines - height) / 2,
        --     style = "minimal",
        --     border = "rounded",
        -- }

        -- -- Create the floating window
        -- local win = vim.api.nvim_open_win(buf, true, opts)
        -- vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat")

        -- Capture user input
        vim.fn.inputsave()
        -- local password = vim.fn.inputsecret("🔒 Agent identified code > ")  -- The user enters credentials
        local password = vim.fn.inputsecret("🔒 password ~ ")
        vim.fn.inputrestore()

        -- Close the floating window after input
        -- vim.api.nvim_win_close(win, true)

        return password
    end

    -- Ask for password using floating window
    local username = vim.fn.input("👾 username ~ ")
    local password = password_prompt()
    -- local username, password = agent_identified_code_input:match("([^@]+)@(.+)")

    -- Validate credentials
    if username and password and valid_users[username] and valid_users[username] == vim.fn.sha256(password) then
        vim.cmd("redraw!")
        vim.cmd("echomsg '✅ Access Granted!'")
        vim.wait(1000)
    else
        vim.cmd("redraw!")
        vim.cmd("echomsg '❌ Access Denied! Exiting...'")
        vim.wait(1300)
        vim.cmd("qall!")
    end
end

return authenticate
