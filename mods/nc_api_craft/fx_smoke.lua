-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, type
    = math, minetest, nodecore, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local smoking = {}

function nodecore.smokefx(pos, time, qty)
	local now = minetest.get_us_time() / 1000000
	local key = minetest.hash_node_position(pos)
	local old = smoking[key]
	if old and now < old.exp then minetest.delete_particlespawner(old.id) end
	if (not time) or (time <= 0) then
		smoking[key] = nil
		return
	end
	if type(qty) ~= "number" then qty = 1 end
	if qty < 1 then
		if math_random() > qty then return end
		qty = 1
	end
	smoking[key] = {
		id = minetest.add_particlespawner({
				texture = "nc_api_craft_smoke.png",
				collisiondetection = true,
				amount = (qty or 2) * time,
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
