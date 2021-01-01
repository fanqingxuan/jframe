local Base = require("controller.base")

local User = Base:extend()

local userModel = require('model.user')

function User:index() 
    self:json({
        data={
            name = userModel:columns('rname'):get(1)
        }
    })
end

function User:list() 
    self:json({
        data={
            name = userModel:columns('suid,rname'):where("suid","<","30"):where("rname","like","%小%"):orderby("suid"):all()
        }
    })
end

function User:create()
    local data = {
        rname = "测试1",
        pwd = '123456'
    }
    local lastId = userModel:create(data)
    self:json({userId=lastId})
end

function User:get()
    local user = userModel:get('1 or 1=1')
    self:json({user=user})

end

function User:update()
    local data = {
        rname = "测试1111",
        pwd = '33333'
    }
    local affect_rowd = userModel:update(data,'1 or 1=1')
    self:json({user=affect_rowd})

end

function User:del()
    local affect_rowd = userModel:where('suid','=',2):soft_delete()
    self:json({user=affect_rowd})

end

return User