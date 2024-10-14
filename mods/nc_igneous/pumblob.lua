-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

for i = 1, 8 do
	core.register_ore({
			name = "lava blob " .. i,
			ore_type = "blob",
			ore = "nc_terrain:lava_source",
			wherein = "nc_terrain:stone",
			clust_size = 1 + math_floor(1.5 ^ (i - 1)),
			clust_scarcity = 32 * 32 * 32,
			random_factor = 0,
			noise_params = {
				offset = -0.1,
				scale = 3,
				spread = {x = 64, y = 16, z = 64},
				seed = 127 - i,
				octaves = 3,
				persist = 0.5,
				flags = "eased",
			},
			noise_threshold = 1.2,
			y_max = -128 * (i - 1)
		})
end

local c_lava = core.get_content_id("nc_terrain:lava_source")
local c_stone = core.get_content_id("nc_terrain:stone")
local c_air = core.get_content_id("air")
nc.register_mapgen_shared({
		label = "lava lake clearance",
		func = function(minp, maxp, area, data, _, _, _, rng)
			local ai = area.index
			for z = minp.z, maxp.z do
				for y = minp.y, maxp.y - 1 do
					local offs = ai(area, 0, y, z)
					local aoffs = ai(area, 0, y + 1, z)
					for x = minp.x, maxp.x do
						if data[offs + x] == c_lava
						and data[aoffs + x] == c_stone
						and rng(1, 2) == 1 then
							data[aoffs + x] = c_air
						end
					end
				end
			end
		end,
		priority = -100
	})
