-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, core, ipairs, math, nc, table
    = VoxelArea, core, ipairs, math, nc, table
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local mapgens = {}
nc.registered_mapgen_shared = mapgens

local singlenode = core.get_mapgen_setting("mg_name") == "singlenode"

local counters = {}
function nc.register_mapgen_shared(def)
	local label = def.label
	if not label then
		label = core.get_current_modname()
		local i = (counters[label] or 0) + 1
		counters[label] = i
		label = label .. ":" .. i
	end

	local prio = def.priority or 0
	def.priority = prio
	local min = 1
	local max = #mapgens + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = mapgens[try].priority
		if (prio < oldp) or (prio == oldp and label > mapgens[try].label) then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(mapgens, min, def)
end

local mapperlin
core.after(0, function() mapperlin = core.get_perlin(0, 1, 0, 1) end)

nc.register_on_generated(function(minp, maxp)
		local vm, emin, emax = core.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

		local rng = nc.seeded_rng(mapperlin:get_3d(minp))

		for _, def in ipairs(mapgens) do
			local en = def.enabled
			if en == nil then en = not singlenode end
			if en then
				def.func(minp, maxp, area, data, vm, emin, emax, rng)
			end
		end

		vm:set_data(data)
		vm:write_to_map()
	end)
