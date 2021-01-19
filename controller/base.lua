local Object = require "libs.classic"
local Request = require "libs.request"
local Response = require "libs.response"

local redisConfig = require("config.redis")
local Redis = require "libs.redis"

local memcachedConfig = require("config.memcached")
local Memcached = require "libs.memcached"

local LocalStorage = require "libs.localStorage"

local redis = Redis:new(redisConfig)
local memcached = Memcached:new(memcachedConfig)
local localStorage = LocalStorage()

local ngx = ngx
local Base = Object:extend()

function Base:new(controller, action)
  self.controller = controller
  self.action = action
  self.request =  Request:new()
  self.response = Response:new()
  self.redis = redis
  self.memcached = memcached
  self.localStorage = localStorage
  self.ngx = ngx
  return self
end

function Base:json(data, code, empty_table_as_object)
    local resp = {
        code = code or 0,
        data = data,
		message = ''
    }
    self.response:json(resp,empty_table_as_object)
end

function Base:error(code,message, empty_table_as_object)
    local resp = {
        code = code or 0,
        data = {},
		message = message or 'empty message'
    }
    self.response:json(resp,empty_table_as_object)
end

return Base