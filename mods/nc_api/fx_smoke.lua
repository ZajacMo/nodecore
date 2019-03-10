-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local smoking = {}

function nodecore.smoke(pos, time)
	local now = minetest.get_us_time() / 1000000
	local key = minetest.hash_node_position(pos)
	local old = smoking[key]
	if old and now < old.exp then minetest.delete_particlespawner(old.id) end
	if (not time) or (time <= 0) then
		smoking[key] = nil
		return
	end
	smoking[key] = {
		id = minetest.add_particlespawner({
				texture = "nc_api_smoke.png",
				collisiondetection = true,
				amount = 4 * time,
				time = time,
				minpos = {x = pos.x - 0.4, y = pos.y - 0.4, z = pos.z - 0.4},
				maxpos = {x = pos.x + 0.4, y = pos.y + 0.4, z = pos.z + 0.4},
				minvel = {x = -0.1, y = 0.3, z = -0.1},
				maxvel = {x = 0.1, y = 0.7, z = 0.1},
				minexptime = 1,
				maxexptime = 5,
				minsize = 1,
				maxsize = 3	
			}),
		exp = now + time
	}
end
