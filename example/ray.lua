-- ray tracing in LuaPlate
-- reference: https://raytracing.github.io

local lp = require('luaplate')
local lpd = require('luaplate.data')
local draw = require('luaplate.draw')
local obj = require('luaplate.obj')

local width, height = 400, 200


--- do ray tracing, returns color vector
local function color_vec(ray, world, depth)
  local rec = world:hit(ray, 1e-3, 1e12)
  if rec then
    local scatt, atten = rec.mat:scatter(ray, rec)
    if depth < 50 and scatt and atten then
      return atten * color_vec(scatt, world, depth + 1)
    else
      return lpd.Vec3(0, 0, 0)
    end
  else
    local unit_dir = ray.d:norm()
    local t = 0.5 * (unit_dir.y + 1)
    return (1 - t) * lpd.Vec3(1, 1, 1) + t * lpd.Vec3(0.5, 0.7, 1)
  end
end


function scene_begin()
  lp.title('RTX on!')
  lp.size(width, height)
  local sample = 16

  -- initialize world & camera
  local world = obj.ObjectList({
    obj.Sphere(lpd.Vec3(0, 0, -1), 0.5, obj.Diffuse(0.1, 0.2, 0.5)),
    obj.Sphere(lpd.Vec3(0, -100.5, -1), 100, obj.Diffuse(0.8, 0.8, 0)),
    obj.Sphere(lpd.Vec3(1, 0, -1), 0.5, obj.Metal(0.8, 0.6, 0.2)),
    obj.Sphere(lpd.Vec3(-1, 0, -1), 0.5, obj.Glass(1.5)),
    obj.Sphere(lpd.Vec3(-1, 0, -1), -0.45, obj.Glass(1.5)),
  })
  local cam = obj.Camera(lpd.Vec3(-2, 2, 1), lpd.Vec3(0, 0, -1),
                         lpd.Vec3(0, 1, 0), 20, width / height)

  for j = 0, height - 1 do
    for i = 0, width - 1 do
      local cv = lpd.Vec3()
      -- antialiasing
      for _ = 1, sample do
        local u = (i + math.random()) / width
        local v = (height - 1 - j + math.random()) / height
        cv = cv + color_vec(cam:ray(u, v), world, 0)
      end
      cv = cv / sample
      cv = lpd.Vec3(math.sqrt(cv.x), math.sqrt(cv.y), math.sqrt(cv.z))
      cv = cv * 255.99
      -- draw point in canvas
      local c = lpd.Color(cv.x, cv.y, cv.z)
      draw.point(lpd.Vec3(i, j), c)
    end
  end
end
