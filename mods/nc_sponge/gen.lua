-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, math, minetest
    = VoxelArea, math, minetest
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local maxy = -8
local miny = maxy - 8

local c_sand = minetest.get_content_id("nc_terrain:sand")
local c_water = minetest.get_content_id("nc_terrain:water_source")
local c_sponge = minetest.get_content_id(modname .. ":sponge_living")


minetest.register_on_generated(function(minp, maxp)
		if minp.y > maxy or maxp.y < miny then return end

		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge =  emax})

		local dirty

		local qty = math_floor(math_random() * (maxp.x - minp.x)
			* (maxp.z - minp.z) / (16 * 16))
		for n = 1, qty do
			local x = math_floor(math_random() * (maxp.x - minp.x)) + minp.x
			local z = math_floor(math_random() * (maxp.z - minp.z)) + minp.z
			minetest.log(x .. "," .. z)
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
					data[area:index(x, y + 1, z)] = c_sponge
					dirty = true
					break
				else
					break
				end
			end
		end

		if not dirty then return end

		vm:set_data(data)
		vm:set_lighting{day = 0, night = 0}
		vm:calc_lighting()
		vm:write_to_map()
	end)
