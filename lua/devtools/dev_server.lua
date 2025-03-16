local DevServer = {}
DevServer.__index = DevServer

function DevServer:__init__(args)
    local args = args or {}
    local obj = setmetatable({}, self)
    obj.docker_compose = args.docker_compose or
    (vim.fn.expand("~") .. "/AppData/Local/nvim/containers/dev")                                             -- Default value
    return obj
end

function DevServer:build()
    vim.cmd("docker-compose --project-directory " .. self.docker_compose)
end

function DevServer:up_d()
    vim.cmd("docker-compose --project-directory " .. self.docker_compose .. " up -d")
end

function DevServer:down()
    vim.cmd("docker-compose --project-directory " .. self.docker_compose .. " down")
end

function DevServer:down_v()
end

function DevServer:connect()
end

return DevServer
