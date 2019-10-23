-- draw some simple graphics to canvas

local lp = require('luaplate')
local draw = require('luaplate.draw')
local lpd = require('luaplate.data')

local width, height = 0, 0
local rp, rw, rh = lpd.Vec3(0, 0), 100, 100
local tri = lpd.Tri(lpd.Vec3(50, 0), lpd.Vec3(0, 150), lpd.Vec3(150, 100))


local function update_rect()
  draw.solid(rp, rw, rh, lpd.BLACK)
  rp.x = rp.x > width and -100 or rp.x + 3
  rp.y = rp.y > height and -100 or rp.y + 3
end

local function update_tri()
  draw.tri(tri, lpd.RED)

  local reset_x = tri.p2.x > width
  local reset_y = tri.p1.y > height
  tri.p1.x = reset_x and -100 or tri.p1.x + 2
  tri.p1.y = reset_y and -150 or tri.p1.y + 2
  tri.p2.x = reset_x and -150 or tri.p2.x + 2
  tri.p2.y = reset_y and    0 or tri.p2.y + 2
  tri.p3.x = reset_x and    0 or tri.p3.x + 2
  tri.p3.y = reset_y and  -50 or tri.p3.y + 2
end

function scene_begin()
  width, height = lp.size()
  rp.x = math.random(0, width - 1)
  rp.y = math.random(0, height - 1)
end

function scene_update()
  draw.fill(lpd.WHITE)
  update_rect()
  update_tri()
end
