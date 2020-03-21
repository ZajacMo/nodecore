-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_ore({
		name = "gravel",
		ore_type = "blob",
		ore = modname .. ":gravel",
		wherein = modname .. ":stone",
		clust_size = 5,
		clust_scarcity = 8 * 8 * 8,
		random_factor = 0,
		noise_params = {
			offset = 0,
			scale = 3,
			spread = {x = 10, y = 25, z = 10},
			seed = 34654,
			octaves = 3,
			persist = 0.5,
			flags = "eased",
		},
		noise_threshold = 1.2
	})

local c_air = minetest.get_content_id("air")
local c_stones = {}
for _, n in pairs(minetest.registered_nodes[modname .. ":stone"].strata) do
	c_stones[minetest.get_content_id(n)] = true
end
local function regspring(label, node, rarity)
	local c_node = minetest.get_content_id(node)
	nodecore.register_mapgen_shared({
			label = label,
			func = function(minp, maxp, area, data)
				local rawqty = math_random() * (maxp.x - minp.x + 1)
				* (maxp.z - minp.z + 1) * (maxp.y - minp.y + 1) / rarity
				local qty = math_floor(rawqty)
				if math_random() < (rawqty - qty) then qty = qty + 1 end

				for _ = 1, qty do
					local x = math_floor(math_random() * (maxp.x - minp.x + 1)) + minp.x
					local y = math_floor(math_random() * (maxp.y - minp.y + 1)) + minp.y
					local z = math_floor(math_random() * (maxp.z - minp.z + 1)) + minp.z
					if c_stones[data[area:index(x, y, z)]]
					and (x < maxp.x and data[area:index(x + 1, y, z)] == c_air
						or x > minp.x and data[area:index(x - 1, y, z)] == c_air
						or y < maxp.y and data[area:index(x, y + 1, z)] == c_air
						or y > minp.y and data[area:index(x, y - 1, z)] == c_air
						or z < maxp.z and data[area:index(x, y, z + 1)] == c_air
						or z > minp.z and data[area:index(x, y, z - 1)] == c_air)
					then data[area:index(x, y, z)] = c_node end
				end
			end
		})
end
local baserarity = 32 * 32 * 32
regspring("water spring", modname .. ":water_source", baserarity)
regspring("lava spring", modname .. ":lava_source", baserarity * 8)
