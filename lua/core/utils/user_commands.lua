local api = vim.api
local authenticate = _G.authenticate
local session = _G.session

-- Custom command to open Explorer tree
api.nvim_create_user_command("Tree", "NvimTreeToggle", {})

-- Custom command to open sleep editor
api.nvim_create_user_command("Lock", function()
    -- Call the authenticate function from the login module
    authenticate.login()
end, {})

api.nvim_create_user_command("Saves", function()
    -- Call the session module
    session:save()
end, {})

api.nvim_create_user_command("Dels", function()
    -- Call the session module
    session:delete()
end, {})

