-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
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
			offset  = 0,
			scale   = 3,
			spread  = {x=10, y=25, z=10},
			seed    = 34654,
			octaves = 3,
			persist = 0.5,
			flags = "eased",
		},
		noise_threshold = 1.2	
	})

local c_stone = minetest.get_content_id(modname .. ":stone")
local hard = {}
for i = 1, nodecore.hard_stone_strata do
	hard[i] = minetest.get_content_id(modname .. ":hard_stone_" .. i)
end
hard[0] = c_stone
nodecore.register_mapgen_shared(function(minp, maxp, area, data, vm, emin, emax)
		if minp.y > -64 then return end
		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				local raw = y / -64
				local strat = math_floor(raw)
				local dither = raw - strat
				if strat > #hard then
					strat = #hard
					dither = nil
				elseif dither > 4/64 then
					dither = nil
				else
					dither = (dither * 64 + 1)/5
				end
				for x = minp.x, maxp.x do
					local i = area:index(x, y, z)
					if data[i] == c_stone then
						if dither and math_random() >= dither then
							data[i] = hard[strat - 1]
						else
							data[i] = hard[strat]
						end
					end
				end
			end
		end
	end)
