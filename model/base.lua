local Object = require "libs.classic"

local DB = require "libs.db"
local dbConfig = require "config.database"
local db = DB:new(dbConfig)

local Base = Object:extend()

function Base:new()
  self.db = db
  return self
end

return Base