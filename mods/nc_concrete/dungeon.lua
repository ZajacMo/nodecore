-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function profile(name)
	return {
		fill = modname .. ":" .. name,
		brick = "nc_stonework:bricks_" .. name,
		bonded = "nc_stonework:bricks_" .. name .. "_bonded",
	}
end

local dirty = profile("adobe")
local sandy = profile("sandstone")
local tarry = profile("coalstone")

local heightperlin
local surfperlin
minetest.after(0, function()
		heightperlin = minetest.get_perlin(4367, 3, 0.5, 8)
		surfperlin = minetest.get_perlin(865, 3, 0.5, 64)
	end)

local oldbricks = nodecore.dungeon_bricks
function nodecore.dungeon_bricks(pos, rng, ...)
	if pos.y >= 32 then
		if pos.y >= 64 or heightperlin:get_3d(pos) < (pos.y / 16 - 3) then
			return surfperlin:get_3d(pos) > 0 and dirty or sandy
		end
		return oldbricks(pos, rng, ...)
	end
	if pos.y >= -640 then return oldbricks(pos, rng) end
	if pos.y < -768 then return tarry end
	if heightperlin:get_3d(pos) > (pos.y / 64 + 11) then return tarry end
	return oldbricks(pos, rng, ...)
end
