-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, next, nodecore, pairs, table
    = ipairs, math, minetest, next, nodecore, pairs, table
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local cobble = modname .. ":cobble"

------------------------------------------------------------------------
-- REGISTER PRIORITIZED DUNGEON MODIFIERS

local dungens = {}
nodecore.registered_dungeongens = dungens

local counters = {}
function nodecore.register_dungeongen(def)
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

local function dungeonprocess(pos, node)
	for _, def in ipairs(dungens) do
		if def.enabled ~= false then
			def.func(pos, node)
			if minetest.get_node(pos).name ~= node.name then return end
		end
	end
	return minetest.set_node(pos, {name = cobble})
end

------------------------------------------------------------------------
-- REGISTER DUNGEON NODES, BIOME DEFAULTS

local function regdungeon(name)
	local def = nodecore.underride({groups = {dungeon_mapgen = 1}},
		minetest.registered_nodes[cobble])
	def.description = "Dungeon Cobble"
	def.tiles = {modname .. "_stone.png^" .. modname .. "_cobble.png"}
	def.mapgen = nil
	return minetest.register_node(modname .. ":" .. name, def)
end

regdungeon("dungeon_cobble")
regdungeon("dungeon_cobble_alt")
regdungeon("dungeon_cobble_stair")

local oldbiome = minetest.register_biome
function minetest.register_biome(def, ...)
	if not def then return oldbiome(def, ...) end
	def.node_dungeon = def.node_dungeon or modname .. ":dungeon_cobble"
	def.node_dungeon_alt = def.node_dungeon_alt or modname .. ":dungeon_cobble_alt"
	def.node_dungeon_stair = def.node_dungeon_stair or modname .. ":dungeon_cobble_stair"
	return oldbiome(def, ...)
end

------------------------------------------------------------------------
-- DUNGEON MODIFIER HOOKS

nodecore.register_lbm({
		name = modname .. ":dungeons",
		run_at_every_load = true,
		nodenames = {"group:dungeon_mapgen"},
		action = dungeonprocess
	})

minetest.register_abm({
		label = modname .. " dungeon cleanup",
		interval = 1,
		chance = 1,
		nodenames = {"group:dungeon_mapgen"},
		action = dungeonprocess
	})

local queue = {}
minetest.register_globalstep(function()
		if not next(queue) then return end
		local batch = queue
		queue = {}
		for _, pos in pairs(batch) do
			local node = minetest.get_node(pos)
			local cid = minetest.get_content_id(node.name)
			if cid == node.cid then dungeonprocess(pos, node) end
		end
	end)

local hash = minetest.hash_node_position

local cid_cobble = minetest.get_content_id(modname .. ":dungeon_cobble")
local cid_cobble_alt = minetest.get_content_id(modname .. ":dungeon_cobble_alt")
local cid_cobble_stair = minetest.get_content_id(modname .. ":dungeon_cobble_stair")

nodecore.register_mapgen_shared({
		label = "dungeon loot",
		func = function(minp, maxp, area, data)
			local ai = area.index
			for z = minp.z, maxp.z do
				for y = minp.y, maxp.y - 1 do
					local offs = ai(area, 0, y, z)
					for x = minp.x, maxp.x do
						local i = offs + x
						local d = data[i]
						if d == cid_cobble
						or d == cid_cobble_alt
						or d == cid_cobble_stair then
							local pos = {x = x, y = y, z = z}
							pos.cid = d
							queue[hash(pos)] = pos
						end
					end
				end
			end
		end,
		priority = -100
	})
