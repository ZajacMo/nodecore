-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor
    = math.floor
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

local queue = {}

minetest.register_globalstep(function()
		for i = 1, #queue do
			minetest.transforming_liquid_add(queue[i])
		end
		queue = {}
	end)

local c_air = minetest.get_content_id("air")
local c_stones = {}
for _, n in pairs(minetest.registered_nodes[modname .. ":stone"].strata) do
	c_stones[minetest.get_content_id(n)] = true
end
local function regspring(label, node, rarity)
	local c_node = minetest.get_content_id(node)
	nodecore.register_mapgen_shared({
			label = label,
			func = function(minp, maxp, area, data, _, _, _, rng)
				local rawqty = rng() * (maxp.x - minp.x + 1)
				* (maxp.z - minp.z + 1) * (maxp.y - minp.y + 1) / rarity
				local qty = math_floor(rawqty)
				if rng() < (rawqty - qty) then qty = qty + 1 end

				for _ = 1, qty do
					local x = rng(minp.x + 1, maxp.x - 1)
					local y = rng(minp.y + 1, maxp.y - 1)
					local z = rng(minp.z + 1, maxp.z - 1)
					local idx = area:index(x, y, z)
					if c_stones[data[idx]]
					and (data[idx - 1] == c_air
						or data[idx + 1] == c_air
						or data[idx - area.ystride] == c_air
						or data[idx + area.ystride] == c_air
						or data[idx - area.zstride] == c_air
						or data[idx + area.zstride] == c_air)
					then
						data[area:index(x, y, z)] = c_node
						queue[#queue + 1] = {x = x, y = y, z = z}
					end
				end
			end
		})
end
local baserarity = 32 * 32 * 32
regspring("water spring", modname .. ":water_source", baserarity)
regspring("lava spring", modname .. ":lava_source", baserarity * 4)
