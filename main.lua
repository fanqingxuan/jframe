local Request = require("libs.request")
local Response = require("libs.response")
local Redis = require("libs.redis")
local redisConfig = require("config.redis")
local appConfig = require("config.app")

local request = Request:new()
local response = Response:new()
local redis = Redis:new(redisConfig)

-- 默认首页
if request.uri == "" or request.uri == "/" then
    local res = ngx.location.capture("/index.html", {})
    ngx.say(res.body)
    return
end

-- url解析
local m, err = ngx.re.match(request.uri, "([a-zA-Z0-9-]+)/*([a-zA-Z0-9-]+)*")

local controller = m[1]     -- 控制器名
local action = m[2]         -- 方法名

if not action then
    action = "index"        -- 默认访问index方法
else
    action = ngx.re.gsub(action, "-", "_")    
end

-- 控制器默认在web包下面
local prefix = "controller."       
local path = prefix .. controller

-- 尝试引入模块，不存在则报错
local ret, ctrl, err = pcall(require, path)

local is_debug = appConfig.debug       -- 调试阶段，会输出错误信息到页面上

if ret == false then
    if is_debug then
        ngx.status = 404
        ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. controller .. "</span> controller not found !</p>")
    end
    
    ngx.exit(404)
end

local _,ctrl,_ = pcall(ctrl,request,response,redis)

local req_method = ctrl[action]

if req_method == nil then
    if is_debug then
        ngx.status = 404
        ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. action .. "()</span> method not found in <span style='color:red'>" .. controller .. "</span> lua module !</p>")
    end
    ngx.exit(404)
end

-- 执行模块方法，报错则显示错误信息，所见即所得，可以追踪lua报错行数
ret, err = pcall(req_method,ctrl)

if ret == false then
    if is_debug then
        ngx.status = 404
        ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. err .. "</span></p>")
    else
        ngx.exit(500)
    end
end
