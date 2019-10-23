-- some utilities

local util = {}


--- clone object (deep copy)
function util.clone(obj)
  local copy
  if type(obj) == 'table' then
    copy = {}
    for k, v in next, obj, nil do
      copy[util.clone(k)] = util.clone(v)
    end
    setmetatable(copy, util.clone(getmetatable(obj)))
  else
    -- number, string, boolean, etc
    copy = obj
  end
  return copy
end

--- copy object (shallow copy)
function util.copy(obj)
  local copy
  if type(obj) == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(obj) do
      copy[orig_key] = orig_value
    end
    setmetatable(copy, getmetatable(obj))
  else
    -- number, string, boolean, etc
    copy = obj
  end
  return copy
end


return util
