-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, vector
    = ipairs, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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

function nodecore.leaf_decay(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.leaf_decay_as then
		for k, v in pairs(def.leaf_decay_as) do
			node[k] = v
		end
	end
	local t = {}
	local forced = minetest.get_meta(pos):get_string("leaf_drop_force")
	forced = forced and forced ~= "" and minetest.deserialize(forced, true) or nil
	if forced then
		t = forced
	else
		for _, v in ipairs(nodecore.registered_leaf_drops) do
			t = v(pos, node, t) or t
		end
	end
	local p = nodecore.pickrand(t, function(x) return x.prob or 1 end)
	if not p then return end
	minetest.set_node(pos, p)
	if p.item then nodecore.item_eject(pos, p.item) end
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
	return nodecore.fallcheck(pos)
end

local cache = {}

local function check_decay(pos, node)
	local hash = minetest.hash_node_position(pos)
	local found = cache[hash]
	if found and minetest.get_node(found).name == found.name then return true end
	return nodecore.scan_flood(pos, 5, function(p)
			local n = minetest.get_node(p).name
			if n == modname .. ":tree"
			or n == modname .. ":tree_bud"
			or n == "ignore" then
				while p.prev do
					p.name = minetest.get_node(p).name
					cache[minetest.hash_node_position(p.prev)] = p
					p = p.prev
				end
				return true
			end
			if n == modname .. ":leaves"
			or n == modname .. ":leaves_bud" then
				return
			end
			return false
		end
	) or nodecore.leaf_decay(pos, node)
end

local decaynames = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.leaf_decay
			and v.groups.leaf_decay > 0 then
				decaynames[k] = true
			end
		end
	end)

minetest.register_globalstep(function()
		if qsize < 1 then return end
		local batch = queue
		queue = {}
		qsize = 0
		for i = #batch, 2, -1 do
			local j = math_random(1, i)
			if j ~= i then
				local tmp = batch[i]
				batch[j] = batch[i]
				batch[i] = tmp
			end
		end
		for i = 1, #batch do
			local pos = batch[i]
			local node = minetest.get_node(pos)
			if decaynames[node.name] then
				check_decay(pos, node)
			end
		end
	end)

minetest.register_abm({
		label = "leaves decay",
		interval = 2,
		chance = 5,
		nodenames = {"group:leaf_decay"},
		action = check_decay
	})
