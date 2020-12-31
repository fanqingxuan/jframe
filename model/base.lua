local Object = require "libs.classic"

local DB = require "libs.db"
local dbConfig = require "config.database"
local db = DB:new(dbConfig)
local ngx = ngx
local Base = Object:extend()

local function transform_value(value)
	if value == ngx.null then
		value = ''
	end
	value = value or ''
	if string.lower(value) == 'null' then
		return 'NULL'
	end
	return ngx.quote_sql_str(value)
end

function Base:new(table,pk,soft_delete_column)
  self.table = table
  self.soft_delete_column = soft_delete_column or 'deleted_at'
  self.query_sql = nil
  self.has_order_by = false
  self.pk = pk or 'id'
  self.fields = '*'
  return self
end

function Base:query(sql,params)
	if not sql then
		return ngx.log(ngx.ERR,'query() function need sql to query')
	end	
	local result, err = db:query(sql, params)
	if not result then
		ngx.exit(500)
		return
	end
	return result
end 

function Base:create(data) 
	local columns,values
	for column,value in pairs(data) do
		value = transform_value(value)
		if not columns then
			columns = column
			values = value
		else
			columns = columns..','..column
			values = values..','..value
		end
	end
	return self:query('insert into '..self.table..'('..columns..') values('..values..')').insert_id
end

function Base:delete(id)
	id = id or nil
	if not id then
		-- 拼接需要delete的字段
		if self.query_sql then
			local sql = 'delete from '..self.table..' '..self.query_sql
			return self:query(sql).affected_rows
		end
		ngx.log(ngx.ERR,'delete function need prefix sql')
		ngx.exit(500)
	else
		return self:query('delete from '..self.table..' where '..self.pk..'=' .. id).affected_rows
	end
	return false
end

function Base:soft_delete()
	id = id or nil
	if not id then
		-- 拼接需要delete的字段
		if self.query_sql then
			local sql = 'update '..self.table..' set '..self.soft_delete_column..' = now() '.. self.query_sql
			return self:query(sql).affected_rows
		end
		ngx.log(ngx.ERR,'delete function need prefix sql')
		ngx.exit(500)
	else
		return self:query('update '..self.table..' set '..self.soft_delete_column..' = now()'..' where '..self.pk..'=' .. id).affected_rows
	end
	return false
	
end

function Base:update(data,id)
	local id = id or nil
	-- 拼接需要update的字段
	local str = nil
	for column,value in pairs(data) do
		clean_value = transform_value(value)
		if not str then
			str = column..'='..clean_value
		else
			str = str..','..column..'='..clean_value
		end
	end
	id = data[self.pk] or id
	if not id then
		if self.query_sql then
			local sql = 'update '..self.table..' set '..str..' '..self.query_sql
			return self:query(sql).affected_rows
		end
		ngx.log(ngx.ERR,'update function cannot called without restriction')
		ngx.exit(500)
	else
		local sql = 'update '..self.table..' set '..str..' where '..self.pk..'='..id
		return self:query(sql).affected_rows
	end
	return false
end

function Base:get(id)
	id = tonumber(id)
	local where = self.query_sql;
	if id then 
		where = ' where '..self.pk..'='..id;
	else 
		
	end
	local sql = 'select '..self.fields..' from '..self.table..where..' limit 1'
	local res = self:query(sql)
	if table.getn(res) > 0 then
		return res[1]
	else
		return false
	end
end

function Base:all()
	local where = self.query_sql;
	local sql = 'select '..self.fields..' from '..self.table..self.query_sql
	local res = self:query(sql)
	return res
end

function Base:where(column,operator,value)
	value = transform_value(value)
	if not self.query_sql then
		self.query_sql = ' where '..column.. ' ' .. operator .. ' ' .. value
	else
		self.query_sql = self.query_sql..' and '..column..' '..operator..' '..value
	end
	return self
end

function Base:orderby(column,operator)
	local operator = operator or 'asc'
	if not self.query_sql then
		self.query_sql = ' order by '.. self.table .. '.' .. column .. ' ' ..operator
	else
		if self.has_order_by then
			self.query_sql = self.query_sql .. ',' .. column.. ' ' ..operator
		else
			self.query_sql = self.query_sql .. ' order by ' .. column.. ' ' ..operator
		end
	end
	self.has_order_by = true
	return self
end

function Base:count()
	local sql = self.query_sql
	if not sql then
		sql = 'select count(*) from '..self.table
	else
		sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	local res = self:query(sql)
	if table.getn(res) > 0 then
		return tonumber(res[1]['count(*)'])
	else
		return 0
	end
end

function Base:columns(column)
	ngx.say(type(column))
	if type(column) == 'string' then
		self.fields = column
	elseif type(column) == 'table' then
		self.fields = table.concat(column,',')
	else
		ngx.log(ngx.ERR,"columns function must give parameter as string or table")
		ngx.exit(500)
	end
	return self
end

return Base