local Base = require "model.base"

local Post = Base:extend()

function Post:findAll()
    local sql = "SELECT * FROM post"
    return self.db:query(sql)
end

return Post