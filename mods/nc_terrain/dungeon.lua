-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, table
    = core, ipairs, math, nc, table
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local cobble = modname .. ":cobble"

------------------------------------------------------------------------
-- REGISTER PRIORITIZED DUNGEON MODIFIERS

local dungens = {}
nc.registered_dungeongens = dungens

local counters = {}
function nc.register_dungeongen(def)
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
	local max = #dungens + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = dungens[try].priority
		if (prio < oldp) or (prio == oldp and label > dungens[try].label) then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(dungens, min, def)
end

local mapperlin
core.after(0, function() mapperlin = core.get_perlin(45821, 1, 0, 1) end)

local function dungeonprocess(pos, node)
	local rng = nc.seeded_rng(mapperlin:get_3d(pos))
	for _, def in ipairs(dungens) do
		if def.enabled ~= false then
			def.func(pos, node, rng)
			if core.get_node(pos).name ~= node.name then return end
		end
	end
	return core.set_node(pos, {name = cobble})
end

------------------------------------------------------------------------
-- REGISTER DUNGEON NODES, BIOME DEFAULTS

local function regdungeon(name)
	local def = nc.underride({
			groups = {dungeon_mapgen = 1},
			visinv_bulk_optimize = false,
		},
		core.registered_nodes[cobble])
	def.mapgen = nil
	return core.register_node(modname .. ":" .. name, def)
end

regdungeon("dungeon_cobble")
regdungeon("dungeon_cobble_alt")
regdungeon("dungeon_cobble_stair")

local oldbiome = core.register_biome
function core.register_biome(def, ...)
	if not def then return oldbiome(def, ...) end
	def.node_dungeon = def.node_dungeon or modname .. ":dungeon_cobble"
	def.node_dungeon_alt = def.node_dungeon_alt or modname .. ":dungeon_cobble_alt"
	def.node_dungeon_stair = def.node_dungeon_stair or modname .. ":dungeon_cobble_stair"
	return oldbiome(def, ...)
end

------------------------------------------------------------------------
-- DUNGEON MODIFIER HOOKS

nc.register_lbm({
		name = modname .. ":dungeons",
		run_at_every_load = true,
		nodenames = {"group:dungeon_mapgen"},
		action = dungeonprocess
	})

core.register_abm({
		label = modname .. " dungeon cleanup",
		interval = 1,
		chance = 1,
		nodenames = {"group:dungeon_mapgen"},
		action = dungeonprocess
	})
