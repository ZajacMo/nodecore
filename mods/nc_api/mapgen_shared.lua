-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, ipairs, math, minetest, nodecore, table
    = VoxelArea, ipairs, math, minetest, nodecore, table
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local mapgens = {}
nodecore.registered_mapgen_shared = mapgens

function nodecore.register_mapgen_shared(def)
	if minetest.get_mapgen_setting("mg_name") == "singlenode"
	and not def.allow_singlenode then return end

	local prio = def.priority or 0
	def.priority = prio
	local min = 1
	local max = #mapgens + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = mapgens[try].priority
		if prio < oldp then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(mapgens, min, def)
end

minetest.register_on_generated(function(minp, maxp)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

		for _, v in ipairs(mapgens) do
			v.func(minp, maxp, area, data, vm, emin, emax)
		end

		vm:set_data(data)
		vm:write_to_map()
	end)
