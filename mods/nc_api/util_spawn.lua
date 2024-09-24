-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local expire = 0
local zero = vector.zero()
local spawn = zero

function nodecore.spawn_point()
	if nodecore.gametime > expire then
		expire = nodecore.gametime + 5
		spawn = minetest.setting_get_pos("static_spawnpoint") or zero
	end
	return {x = spawn.x, y = spawn.y, z = spawn.z}
end
