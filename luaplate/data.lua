-- definition of basic data structures

local data = {}


--- 3d vector
data.Vec3 = {}
data.Vec3.__index = data.Vec3

setmetatable(data.Vec3, {
  __call = function (self, ...)
    return self.new(...)
  end
})

function data.Vec3.new(x, y, z)
  local self = setmetatable({}, data.Vec3)
  self.x = x or 0
  self.y = y or 0
  self.z = z or 0
  return self
end

--- make a random vector which is inside of unit sphere
function data.Vec3.rand_unit_sphere()
  local p
  repeat
    p = 2 * data.Vec3(math.random(), math.random(), math.random())
    p = p - data.Vec3(1, 1, 1)
  until p:sqr_len() < 1
  return p
end

function data.Vec3.__tostring(self)
  return '(' .. self.x .. ', ' .. self.y .. ', ' .. self.z .. ')'
end

function data.Vec3.__unm(self)
  return data.Vec3(-self.x, -self.y, -self.z)
end

function data.Vec3.__add(lhs, rhs)
  return data.Vec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
end

function data.Vec3.__sub(lhs, rhs)
  return data.Vec3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
end

function data.Vec3.__mul(lhs, rhs)
  if type(lhs) == 'table' and type(rhs) == 'table' then
    return data.Vec3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
  elseif type(lhs) == 'table' then
    return data.Vec3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
  else
    return data.Vec3(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
  end
end

function data.Vec3.__div(lhs, rhs)
  if type(lhs) == 'table' and type(rhs) == 'table' then
    return data.Vec3(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z)
  elseif type(lhs) == 'table' then
    return data.Vec3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
  else
    return data.Vec3(lhs / rhs.x, lhs / rhs.y, lhs / rhs.z)
  end
end

--- dot product
function data.Vec3:dot(rhs)
  return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

--- cross product
function data.Vec3:cross(rhs)
  return data.Vec3(self.y * rhs.z - self.z * rhs.y,
                   self.z * rhs.x - self.x * rhs.z,
                   self.x * rhs.y - self.y * rhs.x)
end

--- get squared length of vector
function data.Vec3:sqr_len()
  return self.x ^ 2 + self.y ^ 2 + self.z ^ 2
end

--- get length of vector
function data.Vec3:len()
  return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

--- return a normalized vector
function data.Vec3:norm()
  local k = 1 / math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
  return data.Vec3(self.x * k, self.y * k, self.z * k)
end

--- get reflected vector by specific normal vector
function data.Vec3:reflect(norm)
  local dot = self.x * norm.x + self.y * norm.y + self.z * norm.z
  return self - 2 * dot * norm
end

--- get refracted vector by specific normal vector
-- @param norm  normal vector
-- @param nn    ni over nt, which n is refractive index
-- @return      nil if is total internal reflection
function data.Vec3:refract(norm, nn)
  local uv = self:norm()
  local dt = uv:dot(norm)
  local det = 1 - nn ^ 2 * (1 - dt ^ 2)
  if det > 0 then
    return nn * (uv - norm * dt) - norm * math.sqrt(det)
  else
    return nil
  end
end


--- ray with origin and direction
data.Ray = {}
data.Ray.__index = data.Ray

setmetatable(data.Ray, {
  __call = function (self, ...)
    return self.new(...)
  end
})

function data.Ray.new(o, d)
  local self = setmetatable({}, data.Ray)
  self.o = o or data.Vec3()
  self.d = d or data.Vec3()
  return self
end

function data.Ray.__tostring(self)
  return tostring(self.o) .. ' -> ' .. tostring(self.d)
end

--- get ray vector by argument 't'
function data.Ray.__call(self, t)
  return self.o + self.d * t
end


--- make a triangle (with three 3d vectors)
function data.Tri(p1, p2, p3)
  return {
    p1 = p1 or data.Vec3(),
    p2 = p2 or data.Vec3(),
    p3 = p3 or data.Vec3(),
  }
end


--- make a mesh (including many triangles)
function data.Mesh(...)
  return {...}
end


--- make a matrix (4 * 4 numbers)
function data.Mat4()
  local mat = {}
  for i = 1, 4 do
    mat[i] = {}
    for j = 1, 4 do
      mat[i][j] = 0
    end
  end
  return mat
end


--- make a color data (including R, G, B and A channel)
function data.Color(rgba, g, b, a)
  if rgba then
    if g then
      return {r = rgba, g = g, b = b, a = a or 0xff}
    else
      local cr = rgba / (2 ^ 24)
      local cg = (rgba / (2 ^ 16)) % 256
      local cb = (rgba / (2 ^ 8)) % 256
      local ca = rgba % 256
      return {r = cr, g = cg, b = cb, a = ca}
    end
  end
end


-- some constants of color
data.WHITE  = data.Color(0xffffffff)
data.BLACK  = data.Color(0x000000ff)
data.RED    = data.Color(0xff0000ff)
data.GREEN  = data.Color(0x00ff00ff)
data.BLUE   = data.Color(0x0000ffff)


return data
