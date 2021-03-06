local Base = require("controller.base")
local good = require "model.good"

local Home = Base:extend()

function Home:index()
    -- local ok = cache:rpush("ll",2)
    local value,cas = self.memcached:set("aaa",43)
    self:json({data={set=ok,get=value,cas=cas,hello='hello'}})
end

function Home:test() 
	self.response:redirect("http://www.baidu.com")
end

function Home:cacheGet()
	self.redis:set("hello","this 是我们")
	self:json({data=self.redis:get('hello')})
end

function Home:cacheMget()
	self.redis:mset("hello11","this 是我们","dd","哈哈哈")
	self:json({data=self.redis:mget('hello11')})
end

function Home:cacheHget()
	self.redis:hmset("H","A","AAAAA","B","BBBBB")
	self:json({data=self.redis:hgetall('H')})
end

function Home:cachelist()
	self.redis:lpush("list","A","AAAAA","B","BBBBB")
	self:json({data=self.redis:lrange('list',0,-1)},"获取成功")
end

function Home:show() 
    self:json({data={controller=self.controller,action=self.action,get=self.request.query}})
end

function Home:list()
    self.redis:set("test","测试")
    self:json({data=self.redis:get("test")})
end

function Home:err()
	self:error(2,"获取数据失败")
end


function Home:get_good()
    self:json(good:get(11666))
end

function Home:get1()
    self:json(good:where('sno','=','020300366'):get())
end

function Home:getx()
    self:json(good:where('sno','=','020300366'):columns('lgid,name,std,sno'):get())
end

function Home:getxx()
    self:json(good:where('lgid','=','1'):columns({'lgid','name'}):get())
end

function Home:all()
    self:json(good:where('sno','=','020300366'):all())
end

function Home:allx()
    self:json(good:where('sno','=','020300366'):columns('lgid,name,std,sno'):all())
end

function Home:allxx()
    self:json(good:where('sno','=','020300366'):columns({'lgid','name'}):all())
end

function Home:count()
    self:json(good:where('sno','!=','020300366'):count())
end

function Home:orderby()
    self:json(good:orderby('name','asc'):orderby('lgid'):all())
end

function Home:update()
	local data = {
		name = "hello 2222",
	}
	local ret = good:where("lgid","=","7"):update(data)
	self:json(ret)
end

function Home:update1()
	local data = {
		name = "hello 测试",
	}
	local ret = good:update(data,2)
	self:json(ret)
end

function Home:update2()
	local data = {
		lgid = "1",
		name = "hello 我的测试",
	}
	local ret = good:update(data)
	self:json(ret)
end

function Home:create()
	local data = {
		name = "hello world",
		
	}
	local ret = good:create(data)
	self:json(ret)
end

function Home:del()
	local ret = good:delete(2)
	self:json(ret)
end

function Home:del1()
	local ret = good:where("name","=","hello world"):delete()
	self:json(ret)
end

function Home:del1()
	local ret = good:query("update lgt_good set name = 'hello' where lgid=? and name=?",{1,'hello'})
	self:json(ret)
end
return Home
