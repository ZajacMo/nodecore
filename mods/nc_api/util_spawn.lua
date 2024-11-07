-- LUALOCALS < ---------------------------------------------------------
local core, nc, vector
    = core, nc, vector
-- LUALOCALS > ---------------------------------------------------------

local expire = 0
local zero = vector.zero()
local spawn = zero

function nc.spawn_point()
	if nc.gametime > expire then
		expire = nc.gametime + 5
		spawn = core.setting_get_pos("static_spawnpoint") or zero
	end
	return {x = spawn.x, y = spawn.y, z = spawn.z}
end
