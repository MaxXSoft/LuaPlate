-- definitions of all 3d objects

local obj = {}
local data = require('luaplate.data')


--- hit record
-- @param t     solved argument 't' for getting a ray vector
-- @param p     ray vector
-- @param norm  normal vector
-- @param mat   material info
function obj.HitRecord(t, p, norm, mat)
  return {
    t = t or 0,
    p = p or data.Vec3(),
    norm = norm or data.Vec3(),
    mat = mat,
  }
end


--- sphere
obj.Sphere = {}
obj.Sphere.__index = obj.Sphere

setmetatable(obj.Sphere, {
  __call = function (self, ...)
    return self.new(...)
  end
})

--- constructor
-- @param mat material info
function obj.Sphere.new(center, radius, mat)
  local self = setmetatable({}, obj.Sphere)
  self.center = center or data.Vec3()
  self.radius = radius or 0
  self.mat = mat
  return self
end

--- get the hit record of current sphere
-- return nil if not hit, otherwise return a HitRecord
function obj.Sphere:hit(ray, t_min, t_max)
  -- solve dot(d, d)t^2 + 2dot(d, o-c)t + dot(o-c, o-c) - r^2 = 0
  local oc = ray.o - self.center
  local a = ray.d:dot(ray.d)
  local b = ray.d:dot(oc)
  local c = oc:dot(oc) - self.radius ^ 2
  local det = b ^ 2 - a * c
  -- generate hit record
  if det > 0 then
    -- check front
    local t = (-b - math.sqrt(det)) / a
    if t > t_min and t < t_max then
      local p = ray(t)
      return obj.HitRecord(t, p, (p - self.center) / self.radius, self.mat)
    end
    -- check back
    t = (-b + math.sqrt(det)) / a
    if t > t_min and t < t_max then
      local p = ray(t)
      return obj.HitRecord(t, p, (p - self.center) / self.radius, self.mat)
    end
  end
  -- return nil if not hit
  return nil
end


--- list of 3d objects
obj.ObjectList = {}
obj.ObjectList.__index = obj.ObjectList

setmetatable(obj.ObjectList, {
  __call = function (self, ...)
    return self.new(...)
  end
})

function obj.ObjectList.new(list)
  local self = setmetatable({}, obj.ObjectList)
  self.list = list
  return self
end

--- get the hit record of current object list
function obj.ObjectList:hit(ray, t_min, t_max)
  local rec = nil
  local closest = t_max
  -- traverse objects
  for _, i in ipairs(self.list) do
    -- get hit record of current object
    local cur = i:hit(ray, t_min, closest)
    -- update closest 't'
    if cur then
      rec = cur
      closest = rec.t
    end
  end
  return rec
end


--- camera
obj.Camera = {}
obj.Camera.__index = obj.Camera

setmetatable(obj.Camera, {
  __call = function (self, ...)
    return self.new(...)
  end
})

--- constructor
-- @param from    position of camera
-- @param look_at direction of camera #1
-- @param up      direction of camera #2
-- @param fov     field of view in degress
-- @param aspect  aspect of field
function obj.Camera.new(from, look_at, up, fov, aspect)
  local self = setmetatable({}, obj.Camera)
  -- calculate some parameters
  local theta = fov * math.pi / 180
  local half_height = math.tan(theta / 2)
  local half_width = aspect * half_height
  local w = (from - look_at):norm()
  local u = up:cross(w):norm()
  local v = w:cross(u)
  -- initialize scan vectors
  self.lower_left = from - half_width * u - half_height * v - w
  self.horizontal = 2 * half_width * u
  self.vertical = 2 * half_height * v
  self.origin = from
  return self
end

-- get current ray by argument 'u' and 'v'
function obj.Camera:ray(u, v)
  return data.Ray(self.origin, self.lower_left + u * self.horizontal +
                  v * self.vertical - self.origin)
end


--- diffuse material
obj.Diffuse = {}
obj.Diffuse.__index = obj.Diffuse

setmetatable(obj.Diffuse, {
  __call = function (self, ...)
    return self.new(...)
  end
})

--- constructor
-- @param ar    albedo of red
-- @param ag    albedo of green
-- @param ab    albedo of blue
function obj.Diffuse.new(ar, ag, ab)
  local self = setmetatable({}, obj.Diffuse)
  self.albedo = data.Vec3(ar or 0.5, ag or 0.5, ab or 0.5)
  return self
end

--- scatter of diffuse material
-- @param   ray   input ray
-- @param   rec   hit record
-- @return  scatt scattered ray
-- @return  atten vector of attenuation in RGB
function obj.Diffuse:scatter(ray, rec)
  local target = rec.p + rec.norm + data.Vec3.rand_unit_sphere()
  local scatt = data.Ray(rec.p, target - rec.p)
  local atten = self.albedo
  return scatt, atten
end


--- metal material
obj.Metal = {}
obj.Metal.__index = obj.Metal

setmetatable(obj.Metal, {
  __call = function (self, ...)
    return self.new(...)
  end
})

--- constructor
-- @param ar    albedo of red
-- @param ag    albedo of green
-- @param ab    albedo of blue
-- @param fuzz  fuzziness
function obj.Metal.new(ar, ag, ab, fuzz)
  local self = setmetatable({}, obj.Metal)
  self.albedo = data.Vec3(ar or 0.5, ag or 0.5, ab or 0.5)
  self.fuzz = fuzz or 0
  if self.fuzz > 1 then self.fuzz = 1 end
  return self
end

--- scatter of metal material
-- @param   ray   input ray
-- @param   rec   hit record
-- @return  scatt scattered ray
-- @return  atten vector of attenuation in RGB
function obj.Metal:scatter(ray, rec)
  -- get reflected vector
  local reflected = ray.d:norm():reflect(rec.norm)
  if self.fuzz then
    reflected = reflected + self.fuzz * data.Vec3.rand_unit_sphere()
  end
  -- make return values
  local scatt = data.Ray(rec.p, reflected)
  local atten = self.albedo
  if scatt.d:dot(rec.norm) > 0 then
    return scatt, atten
  else
    return nil, nil
  end
end


--- glass (dielectric) material
obj.Glass = {}
obj.Glass.__index = obj.Glass

setmetatable(obj.Glass, {
  __call = function (self, ...)
    return self.new(...)
  end
})

--- constructor
-- @param ref_index refractive index of material
function obj.Glass.new(ref_index)
  local self = setmetatable({}, obj.Glass)
  self.ref_index = ref_index
  return self
end

--- Schlick's approximation
local function schlick(cos, ref_index)
  local r0 = (1 - ref_index) / (1 + ref_index)
  r0 = r0 ^ 2
  return r0 + (1 - r0) * (1 - cos) ^ 5
end

--- scatter of metal material
-- @param   ray   input ray
-- @param   rec   hit record
-- @return  scatt scattered ray
-- @return  atten vector of attenuation in RGB
function obj.Glass:scatter(ray, rec)
  local reflected = ray.d:reflect(rec.norm)
  local atten = data.Vec3(1, 1, 1)
  -- determine outward normal vector and nn
  local out_norm, nn, cos
  if ray.d:dot(rec.norm) > 0 then
    out_norm = -rec.norm
    nn = self.ref_index
    cos = self.ref_index * ray.d:dot(rec.norm) / ray.d:len()
  else
    out_norm = rec.norm
    nn = 1 / self.ref_index
    cos = -ray.d:dot(rec.norm) / ray.d:len()
  end
  -- do refract
  local refracted = ray.d:refract(out_norm, nn)
  local prob = not refracted and 1 or schlick(cos, self.ref_index)
  if math.random() < prob then
    return data.Ray(rec.p, reflected), atten
  else
    return data.Ray(rec.p, refracted), atten
  end
end


return obj
