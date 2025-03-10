local api = vim.api
authenticate = require('core.session.authenticate')

local Session = require('core.session.session')
session = Session:__init__{
  is_autoload = true
}

-- Custom command to open Explorer tree
api.nvim_create_user_command("Tree", "NvimTreeToggle", {})

-- Custom command to open sleep editor
api.nvim_create_user_command("Sleep", function()
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

-- AutoCmd to set cursor style at startup and reset on exit
api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
  callback = function()
    local mode = vim.fn.expand("<amatch>") == "VimEnter" and
      "n-v:ver25-blinkon500,i-c-ci-ve:ver25-blinkon500,r-cr-o:hor20-blinkon500"
      or "a:ver25-blinkon500"
    vim.opt.guicursor = mode
  end,
})

api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.defer_fn(function()
        -- ───────────────────────────────────────────────────────────
        -- 🔧 Login Import here for seemless
        -- ───────────────────────────────────────────────────────────
        authenticate.login()
        session:load()
        end, 100)  -- Delay of 100ms to ensure all plugins are fully loaded
    end,
})
