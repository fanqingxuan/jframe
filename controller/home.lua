local Base = require("controller.base")
local Post = require "model.post"
local post = Post()

local Home = Base:extend()

function Home:index() 
    self:json({success=true,data={}})
end

function Home:list()
    self.redis:set("test","测试")
    self:json(444)
end

function Home:getPost()
    self:json(post:findAll())
end
return Home
