-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, ipairs, minetest, nodecore
    = VoxelArea, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_mapgen_shared,
nodecore.registered_mapgen_shared
= nodecore.mkreg()

minetest.register_on_generated(function(minp, maxp)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge =  emax})

		for _, v in ipairs(nodecore.registered_mapgen_shared) do
			v(minp, maxp, area, data, vm, emin, emax)
		end

		vm:set_data(data)
		vm:set_lighting({day = 0, night = 0})
		vm:calc_lighting()
		vm:write_to_map()
	end)
