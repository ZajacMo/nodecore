-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local maxy = -8
local miny = maxy - 8

local c_sand = minetest.get_content_id("nc_terrain:sand")
local c_water = minetest.get_content_id("nc_terrain:water_source")
local c_sponge = minetest.get_content_id(modname .. ":sponge_living")

nodecore.register_mapgen_shared(function(minp, maxp, area, data)
		if minp.y > maxy or maxp.y < miny then return end

		local qty = math_floor(math_random() * (maxp.x - minp.x)
			* (maxp.z - minp.z) / (64 * 64))
		for _ = 1, qty do
			local x = math_floor(math_random() * (maxp.x - minp.x)) + minp.x
			local z = math_floor(math_random() * (maxp.z - minp.z)) + minp.z
			local starty = maxp.y
			if starty > (maxy + 1) then starty = (maxy + 1) end
			local endy = minp.y
			if endy < miny then endy = miny end
			local waterabove = nil
			for y = starty, endy, -1 do
				local idx = area:index(x, y, z)
				local cur = data[idx]
				if cur == c_water then
					waterabove = true
				elseif cur == c_sand and waterabove then
					local i = area:index(x, y + 1, z)
					data[i] = c_sponge
					break
				else
					break
				end
			end
		end
	end)
