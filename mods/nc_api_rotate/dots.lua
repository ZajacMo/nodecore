-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, vector
    = ipairs, minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hashpos = minetest.hash_node_position
local rotation_center_ratio = nodecore.rotation_center_ratio

local dots = {}
do
	local dirs = nodecore.dirs()
	for _, ptnorm in ipairs(dirs) do
		local list = {}
		dots[hashpos(ptnorm)] = list
		for m = 1, #dirs do
			local a = dirs[m]
			if vector.dot(ptnorm, a) == 0 then
				for n = m + 1, #dirs do
					local b = dirs[n]
					if vector.dot(ptnorm, b) == 0
					and vector.dot(a, b) == 0 then
						list[#list + 1] = vector.multiply(
							vector.add(a, b), 0.5)
						list[#list + 1] = vector.multiply(
							vector.add(a, b), rotation_center_ratio)
					end
				end
			end
		end
	end
end

function nodecore.rotation_hud_dots(player, pos, ptnorm, scale)
	local list = pos and ptnorm and scale and dots[hashpos(ptnorm)]
	if list then
		for i = 1, #list do
			nodecore.hud_set(player, {
					label = modname .. "_dot" .. i,
					hud_elem_type = "image_waypoint",
					text = "nc_api_rotate_huddot.png",
					scale = {x = 1, y = 1},
					world_pos = vector.add(pos, vector.multiply(list[i], scale)),
					precision = 0,
				})
		end
	else
		for i = 1, 8 do
			nodecore.hud_set(player, {
					label = modname .. "_dot" .. i,
					ttl = 0,
				})
		end
	end
end
