local Object = require "libs.classic"
local ngx  = ngx
local localStorage = Object:extend()

function localStorage:new()
    self.localStorage = ngx.shared.localStorage
    if not self.localStorage then 
        ngx.log(ngx.ERR," not declare shared memory as storage")
        ngx.exit(500)
    end
end

local commands = {
    "get",
    "set",
    "add",
    "replace",
    "delete",
    "incr",
    "lpush",
    "lpop",
    "rpush",
    "rpop",
    "llen",
    "ttl",
    "expire",
    "flush_all"
}

for i = 1, #commands do
    local cmd = commands[i]
    localStorage[cmd] =
            function (self, ...)
                local val,err = self.localStorage[cmd](self.localStorage, ...)
                if err then
                    ngx.log(ngx.ERR,"localStorage command "..cmd.." err:"..err)
                end
                return val
            end
end



return localStorage