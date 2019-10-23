-- draw a 3D cube to canvas
-- reference: https://github.com/OneLoneCoder/videos/blob/master/OneLoneCoder_olcEngine3D_Part1.cpp

local lp = require('luaplate')
local lpd = require('luaplate.data')
local draw = require('luaplate.draw')

-- width and height of canvas
local width, height = lp.size()
-- mesh of cube
local mesh_cube = {
  -- south
  lpd.Tri(lpd.Vec3(0, 0, 0), lpd.Vec3(0, 1, 0), lpd.Vec3(1, 1, 0)),
  lpd.Tri(lpd.Vec3(0, 0, 0), lpd.Vec3(1, 1, 0), lpd.Vec3(1, 0, 0)),
  -- east
  lpd.Tri(lpd.Vec3(1, 0, 0), lpd.Vec3(1, 1, 0), lpd.Vec3(1, 1, 1)),
  lpd.Tri(lpd.Vec3(1, 0, 0), lpd.Vec3(1, 1, 1), lpd.Vec3(1, 0, 1)),
  -- north
  lpd.Tri(lpd.Vec3(1, 0, 1), lpd.Vec3(1, 1, 1), lpd.Vec3(0, 1, 1)),
  lpd.Tri(lpd.Vec3(1, 0, 1), lpd.Vec3(0, 1, 1), lpd.Vec3(0, 0, 1)),
  -- west
  lpd.Tri(lpd.Vec3(0, 0, 1), lpd.Vec3(0, 1, 1), lpd.Vec3(0, 1, 0)),
  lpd.Tri(lpd.Vec3(0, 0, 1), lpd.Vec3(0, 1, 0), lpd.Vec3(0, 0, 0)),
  -- top
  lpd.Tri(lpd.Vec3(0, 1, 0), lpd.Vec3(0, 1, 1), lpd.Vec3(1, 1, 1)),
  lpd.Tri(lpd.Vec3(0, 1, 0), lpd.Vec3(1, 1, 1), lpd.Vec3(1, 1, 0)),
  -- bottom
  lpd.Tri(lpd.Vec3(1, 0, 1), lpd.Vec3(0, 0, 1), lpd.Vec3(0, 0, 0)),
  lpd.Tri(lpd.Vec3(1, 0, 1), lpd.Vec3(0, 0, 0), lpd.Vec3(1, 0, 0)),
}
-- projection matrix
local mat_proj = lpd.Mat4()
-- elapsed time
local elapsed = 0

local function mult_mat_vec(i, o, m)
  o.x = i.x * m[1][1] + i.y * m[2][1] + i.z * m[3][1] + m[4][1]
  o.y = i.x * m[1][2] + i.y * m[2][2] + i.z * m[3][2] + m[4][2]
  o.z = i.x * m[1][3] + i.y * m[2][3] + i.z * m[3][3] + m[4][3]
  local w = i.x * m[1][4] + i.y * m[2][4] + i.z * m[3][4] + m[4][4]
  if w ~= 0 then
    o.x = o.x / w
    o.y = o.y / w
    o.z = o.z / w
  end
end

function scene_begin()
  -- set title
  lp.title('3D Cube')
  -- initialize projection matrix
  local near = 0.1
  local far = 1000
  local fov = 90
  local asp_ratio = height / width
  local fov_rad = 1 / math.tan(fov * 0.5 / 180 * math.pi)
  mat_proj[1][1] = asp_ratio * fov_rad
  mat_proj[2][2] = fov_rad
  mat_proj[3][3] = far / (far - near)
  mat_proj[4][3] = (-far * near) / (far - near)
  mat_proj[3][4] = 1
  mat_proj[4][4] = 0
end

function scene_update()
  -- clear screen
  draw.fill(lpd.BLACK)
  -- initialize rotate matrices
  local rot_z, rot_x = lpd.Mat4(), lpd.Mat4()
  local theta = 1 * elapsed
  rot_z[1][1] = math.cos(theta)
  rot_z[1][2] = math.sin(theta)
  rot_z[2][1] = -math.sin(theta)
  rot_z[2][2] = math.cos(theta)
  rot_z[3][3] = 1
  rot_z[4][4] = 1
  rot_x[1][1] = 1
  rot_x[2][2] = math.cos(theta * 0.5)
  rot_x[2][3] = math.sin(theta * 0.5)
  rot_x[3][2] = -math.sin(theta * 0.5)
  rot_x[3][3] = math.cos(theta * 0.5)
  rot_x[4][4] = 1
  -- draw triangles
  for _, Tri in pairs(mesh_cube) do
    local rotated1, rotated2 = lpd.Tri(), lpd.Tri()
    -- rotate in z-axis
    mult_mat_vec(Tri.p1, rotated1.p1, rot_z)
    mult_mat_vec(Tri.p2, rotated1.p2, rot_z)
    mult_mat_vec(Tri.p3, rotated1.p3, rot_z)
    -- rotate in x-axis
    mult_mat_vec(rotated1.p1, rotated2.p1, rot_x)
    mult_mat_vec(rotated1.p2, rotated2.p2, rot_x)
    mult_mat_vec(rotated1.p3, rotated2.p3, rot_x)
    -- add offset
    rotated2.p1.z = rotated2.p1.z + 2.5
    rotated2.p2.z = rotated2.p2.z + 2.5
    rotated2.p3.z = rotated2.p3.z + 2.5
    -- project to 2d
    local projected = lpd.Tri()
    mult_mat_vec(rotated2.p1, projected.p1, mat_proj)
    mult_mat_vec(rotated2.p2, projected.p2, mat_proj)
    mult_mat_vec(rotated2.p3, projected.p3, mat_proj)
    -- scale into view
    projected.p1.x = (projected.p1.x + 1) * width * 0.5
    projected.p1.y = (projected.p1.y + 1) * height * 0.5
    projected.p2.x = (projected.p2.x + 1) * width * 0.5
    projected.p2.y = (projected.p2.y + 1) * height * 0.5
    projected.p3.x = (projected.p3.x + 1) * width * 0.5
    projected.p3.y = (projected.p3.y + 1) * height * 0.5
    -- draw to canvas
    draw.tri(projected, lpd.WHITE)
  end
  -- increase elapsed time
  elapsed = elapsed + 0.05
end
