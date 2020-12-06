local Base = require("controller.base")

local Index = Base:extend()

function Index:index() 
    self:json({success=true,data={}})
end


return Index
