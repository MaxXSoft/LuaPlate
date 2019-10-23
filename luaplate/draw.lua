-- draw methods in LuaPlate

local draw = {}


--- set or get pen color of canvas
function draw.color(c)
  if c then
    set_color_rgba(c.r, c.g, c.b, c.a)
  else
    local r, g, b, a = get_color()
    local data = require('luaplate.data')
    return data.Color(r, g, b, a)
  end
end

--- fill canvas (with optional color)
function draw.fill(c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  fill()
end

--- draw a point to canvas (with optional color)
function draw.point(p, c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  draw_point(p.x, p.y)
end

--- draw a line to canvas (with optional color)
function draw.line(p1, p2, c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  draw_line(p1.x, p1.y, p2.x, p2.y)
end

--- draw a rectangle to canvas (with optional color)
function draw.rect(p, w, h, c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  draw_rect(p.x, p.y, w, h)
end

--- draw a solid rectangle to canvas (with optional color)
function draw.solid(p, w, h, c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  fill_rect(p.x, p.y, w, h)
end

--- draw a triangle (2d) to canvas (with optional color)
function draw.tri(tri, c)
  if c then set_color_rgba(c.r, c.g, c.b, c.a) end
  draw_line(tri.p1.x, tri.p1.y, tri.p2.x, tri.p2.y)
  draw_line(tri.p2.x, tri.p2.y, tri.p3.x, tri.p3.y)
  draw_line(tri.p3.x, tri.p3.y, tri.p1.x, tri.p1.y)
end


return draw
