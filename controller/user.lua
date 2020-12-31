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

return User