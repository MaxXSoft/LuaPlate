-- control methods of LuaPlate

local luaplate = {}


--- set window title
function luaplate.title(title)
  set_title(title)
end

--- set or get size of canvas
function luaplate.size(width, height)
  if width then
    resize(width, height)
  else
    return get_size()
  end
end

--- quit LuaPlate
function luaplate.quit()
  quit()
end


return luaplate
