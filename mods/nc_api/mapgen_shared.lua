-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, ipairs, math, minetest, nodecore, table
    = VoxelArea, ipairs, math, minetest, nodecore, table
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local mapgens = {}
nodecore.registered_mapgen_shared = mapgens

local prios = {}

function nodecore.register_mapgen_shared(func, prio)
	prio = prio or 0
	local min = 1
	local max = #mapgens + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = prios[try]
		if prio < oldp then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(mapgens, min, func)
	table_insert(prios, min, prio)
end

minetest.register_on_generated(function(minp, maxp)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge =  emax})

		for _, v in ipairs(mapgens) do
			v(minp, maxp, area, data, vm, emin, emax)
		end

		vm:set_data(data)
		vm:write_to_map()
	end)
