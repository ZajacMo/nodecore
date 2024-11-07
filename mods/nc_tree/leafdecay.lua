-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, pairs, table, vector
    = core, ipairs, math, nc, pairs, table, vector
local math_random, table_shuffle
    = math.random, table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local hashpos = core.hash_node_position

local queue = {}
local qsize = 0
local qmax = 100

local dirs = {
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
}

nc.leaf_decay_forced = {}

function nc.leaf_decay(pos, node)
	node = node or core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if def and def.leaf_decay_as then
		for k, v in pairs(def.leaf_decay_as) do
			node[k] = v
		end
	end

	local poskey = hashpos(pos)
	local forced = nc.leaf_decay_forced[poskey]
	or core.get_meta(pos):get_string("leaf_decay_forced")
	nc.leaf_decay_forced[poskey] = nil
	forced = forced and forced ~= "" and core.deserialize(forced, true) or nil

	local t = {}
	if forced then
		if not forced[1] then forced = {forced} end
		t = forced
	else
		for _, v in ipairs(nc.registered_leaf_drops) do
			t = v(pos, node, t) or t
		end
	end

	local p = nc.pickrand(t, function(x) return x.prob or 1 end)
	if not p then return end

	core.set_node(pos, p)
	if p.item then nc.item_eject(pos, p.item) end

	for i = 1, #dirs do
		local dp = vector.add(pos, dirs[i])
		qsize = qsize + 1
		if qsize > qmax then
			local n = math_random(1, qsize)
			if qsize <= qmax then
				queue[n] = dp
			end
		else
			queue[qsize] = dp
		end
	end

	return nc.fallcheck(pos)
end

local cache = {}

local leaf_decay_support = nc.group_expand("group:leaf_decay_support", true)
local leaf_decay_transmit = nc.group_expand("group:leaf_decay_transmit", true)
local function check_decay(pos, node)
	local hash = hashpos(pos)
	local found = cache[hash]
	if found and core.get_node(found).name == found.name then return true end
	return nc.scan_flood(pos, 5, function(p)
			local n = core.get_node(p).name
			if n == "ignore" or leaf_decay_support[n] then
				while p.prev do
					p.name = core.get_node(p).name
					cache[hashpos(p.prev)] = p
					p = p.prev
				end
				return true
			end
			if leaf_decay_transmit[n] then return end
			return false
		end
	) or nc.leaf_decay(pos, node)
end

local decaynames = {}
core.after(0, function()
		for k, v in pairs(core.registered_nodes) do
			if v.groups and v.groups.leaf_decay
			and v.groups.leaf_decay > 0 then
				decaynames[k] = true
			end
		end
	end)

core.register_globalstep(function()
		if qsize < 1 then return end
		local batch = queue
		queue = {}
		qsize = 0
		table_shuffle(batch)
		for i = 1, #batch do
			local pos = batch[i]
			local node = core.get_node(pos)
			if decaynames[node.name] then
				check_decay(pos, node)
			end
		end
	end)

core.register_abm({
		label = "leaves decay",
		interval = 2,
		chance = 5,
		nodenames = {"group:leaf_decay"},
		action = check_decay
	})
