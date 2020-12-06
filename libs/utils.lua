local json = require("cjson")

local _M = {}

function _M.json_encode(data, empty_table_as_object)
    local json_value
    if json.encode_empty_table_as_object then
        -- empty table encoded as array default
        json.encode_empty_table_as_object(empty_table_as_object or false) 
    end
    if require("ffi").os ~= "Windows" then
        json.encode_sparse_array(true)
    end
    pcall(function(d) json_value = json.encode(d) end, data)
    return json_value
end

function _M.json_decode(str)
    local ok, data = pcall(json.decode, str)
    if ok then
        return data
    end
end


return _M