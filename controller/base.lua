local Object = require "libs.classic"

local Base = Object:extend()

function Base:new(request, response,redis)
  self.request = request
  self.response = response
  self.redis = redis
  return self
end

function Base:json(data, code, empty_table_as_object)
    local resp = {
        code = code or 200,
        data = data
    }
    self.response:json(resp,empty_table_as_object)
end

return Base