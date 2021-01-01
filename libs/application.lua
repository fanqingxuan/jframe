local Object = require "libs.classic"
local ngx = ngx
local appConfig = require("config.app")
local pcall = pcall

local Application = Object:extend()
local tmptable = {}

function Application:new()
	self.uri = ngx.var.request_uri
	self.controller = appConfig.default_controller
	self.action = appConfig.default_action
	self.controllerModule = tmptable
	return self
end

function Application:parse()
	-- 默认首页
	if self.uri == "" or self.uri == "/" then
		return
	end

	-- url解析
	local m, err = ngx.re.match(self.uri, "([a-zA-Z0-9-]+)/*([a-zA-Z0-9-]+)*")
	if err then
		ngx.log(ngx.ERR, "parse url err:".. err)
		return
	end
	self.controller = m[1]     -- 控制器名
	local action = m[2]         -- 方法名

	if not action then
		self.action = appConfig.default_action        -- 默认访问index方法
	else
		self.action = ngx.re.gsub(action, "-", "_")    
	end
end

function Application:check() 
	-- 控制器默认在web包下面
	local prefix = "controller."       
	local path = prefix .. self.controller

	if self.controller == 'base' then
		ngx.log(ngx.ERR,"base already as internal module, and can't as controller name")
		ngx.exit(500)
	end
	-- 尝试引入模块，不存在则报错
	local ok, ctrl, err = pcall(require, path)
	if ok == false then
		ngx.log(ngx.ERR,'require file error:'..ctrl)
		local m,err = ngx.re.match(ctrl,"'controller."..self.controller.."' not found")
		if m then 
			ngx.exit(404) --文件不存在
		else
			ngx.exit(500)
		end
		
	end
	
	if type(ctrl) ~= 'table' then 
		ngx.log(ngx.ERR,"controller ".. self.controller .. " is not a standard lua module")
		ngx.exit(500)
	end
	
	if self.action == 'new' then
		ngx.log(ngx.ERR,"action new is a internal method, and can not as request action");
		ngx.exit(500)
	end

	local req_method = ctrl[self.action]

	if req_method == nil then
		ngx.log(ngx.ERR,"action ".. self.action .. " not found in controller "..self.controller)
		ngx.exit(404)
	end
	self.controllerModule = ctrl
end

function Application:run()

	-- 执行模块方法，报错则显示错误信息，所见即所得，可以追踪lua报错行数
	local ok,ctrl,err = pcall(self.controllerModule,self.controller,self.action)
	if ok == false then
		ngx.log(ngx.ERR,"call new method error:"..ctrl);
		ngx.exit(500)
	end
	local ok, err = pcall(ctrl[self.action],ctrl)
	if ok == false then
		ngx.log(ngx.ERR,"call ".. self.action .." action error:"..err);
		ngx.exit(500)
	end
end

return Application