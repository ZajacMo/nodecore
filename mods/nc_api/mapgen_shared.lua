-- LUALOCALS < ---------------------------------------------------------
local PcgRandom, VoxelArea, ipairs, math, minetest, nodecore, table
    = PcgRandom, VoxelArea, ipairs, math, minetest, nodecore, table
local math_floor, math_random, table_insert
    = math.floor, math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

local mapgens = {}
nodecore.registered_mapgen_shared = mapgens

local singlenode = minetest.get_mapgen_setting("mg_name") == "singlenode"

local counters = {}
function nodecore.register_mapgen_shared(def)
	local label = def.label
	if not label then
		label = minetest.get_current_modname()
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
minetest.after(0, function() mapperlin = minetest.get_perlin(0, 1, 0, 1) end)

nodecore.register_on_generated("mapgen shared", function(minp, maxp)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

		local rng = math_random
		if PcgRandom then
			local seed = mapperlin:get_3d({x = minp.x, y = minp.y, z = minp.z})
			seed = math_floor((seed - math_floor(seed)) * 2 ^ 32 - 2 ^ 31)
			local pcg = PcgRandom(seed)
			rng = function(a, b)
				if b then
					return pcg:next(a, b)
				elseif a then
					return pcg:next(1, a)
				end
				return (pcg:next() + 2 ^ 31) / 2 ^ 32
			end
		end

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
