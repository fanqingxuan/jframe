local Object = require "libs.classic"
local ngx  = ngx
local memcached_c = require "resty.memcached"

local Memcached = Object:extend()

function Memcached:new(opts)
    opts = opts or {}
    self.host = opts.host or "127.0.0.1"
    self.port = opts.port or 11211
    self.max_idle_timeout = opts.max_idle_timeout or 10000
    self.pool_size = opts.pool_size or 100
    self.timeout = opts.timeout or 1000
    return self
end

local commands = {
    "set",
    "get_reused_times",
    "add",
    "replace",
    "append",
    "prepend",
    "cas",
    "touch",
    "flush_all",
    "delete",
    "incr",
    "decr",
    "stats",
    "version",
}


function Memcached.connect_mod(self,memc)
    memc:set_timeout(self.timeout)

    local ok, err = memc:connect(self.host, self.port)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect: " .. err)
        ngx.exit(500)
        return
    end
end

function Memcached.get(self,key)
    local memc, err = memcached_c:new()
    if not memc then
        return
    end

    self:connect_mod(memc)

    local result,_,err = memc:get(key)

    if err then
        ngx.log(ngx.ERR, "failed to execute command get, err: " .. err)
    end
    self:set_keepalive_mod(memc)
    return result, err
end

function Memcached.gets(self,key)
    local memc, err = memcached_c:new()
    if not memc then
        return
    end

    self:connect_mod(memc)
    local result, flags, cas_unique, err = memc:gets(key)
    if err then
        ngx.log(ngx.ERR, "failed to execute command gets,err: " .. err)
    end
    self:set_keepalive_mod(memc)
    return result, cas_unique,err
end

function Memcached.set_keepalive_mod(self,memc)
    local ok, err = memc:set_keepalive(self.max_idle_timeout, self.pool_size)
    if not ok then
        ngx.log(ngx.ERR,"cannot set keepalive: " .. err)
        ngx.exit(500)
        return
    end
end

local function do_command(self, cmd, ... )
    
    local memc, err = memcached_c:new()
    if not memc then
        return
    end

    self:connect_mod(memc)

    local fun = memc[cmd]
    local result, err = fun(memc, ...)
    if err then
        ngx.log(ngx.ERR, "execute command "..cmd.." err:"..err)
        return nil, err
    end

   self:set_keepalive_mod(memc)
   return result, err
    
end

for i = 1, #commands do
    local cmd = commands[i]
    Memcached[cmd] =
            function (self, ...)
                return do_command(self, cmd, ...)
            end
end


return Memcached