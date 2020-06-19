-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local optic_queue = {}

local function dirname(pos)
	if pos.x > 0 then return "e" end
	if pos.x < 0 then return "w" end
	if pos.y > 0 then return "u" end
	if pos.y < 0 then return "d" end
	if pos.z > 0 then return "n" end
	if pos.z < 0 then return "s" end
	return ""
end

local function scan(pos, dir, max, deps)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	if (not max) or (max > 16) then max = 16 end
	for _ = 1, max do
		p = vector.add(p, dir)
		if deps then deps[minetest.hash_node_position(p)] = true end
		local node = minetest.get_node(p)
		if node.name == "ignore" then return false, node end
		local def = minetest.registered_items[node.name] or {}
		if not def.sunlight_propagates then return p, node end
		if def.groups and def.groups.visinv then
			local stack = nodecore.stack_get(p)
			def = minetest.registered_items[stack:get_name()]
			if def and def.type == "node" and not def.sunlight_propagates then
				return p, node
			end
		end
	end
end

local function scan_recv(pos, dir, deps)
	local hit, node = scan(pos, dir, nil, deps)
	if not hit then return hit, node end
	local data = minetest.get_meta(hit):get_string("nc_optics")
	if data == "" then return end
	dir = dirname(vector.multiply(dir, -1))
	if not minetest.deserialize(data)[dir] then return end
	return hit, node
end

local function optic_check(pos)
	optic_queue[minetest.hash_node_position(pos)] = pos
end
nodecore.optic_check = optic_check

local function optic_trigger(start, dir, max)
	local pos, node = scan(start, dir, max)
	if not node then return end
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then return optic_check(pos) end
end

local function optic_process(trans, pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then return end
	local def = minetest.registered_items[node.name] or {}

	local ignored
	if def and def.optic_check then
		local deps = {}
		local func = function(dir)
			local hit, hnode = scan_recv(pos, dir, deps)
			ignored = ignored or hit == false
			return hit, hnode
		end
		local nn, res = def.optic_check(pos, node, func, def)
		if (not ignored) and nn then
			trans[minetest.hash_node_position(pos)] = {
				pos = pos,
				nn = nn,
				data = res,
				deps = deps
			}
		end
	end
end

local depidx = {}
local deprev = {}

local function optic_commit(v)
	local meta = minetest.get_meta(v.pos)
	local old = meta:get_string("nc_optics")
	old = old and (old ~= "") and minetest.deserialize(old) or {}

	local updated
	local node = minetest.get_node(v.pos)
	if node.name ~= v.nn then
		node.name = v.nn
		minetest.set_node(v.pos, node)
		updated = true
	end

	local data = {}
	for _, vv in pairs(v.data or {}) do
		data[dirname(vv)] = 1
	end

	local dirty
	for _, dir in pairs(nodecore.dirs()) do
		local dn = dirname(dir)
		if old[dn] ~= data[dn] then
			optic_trigger(v.pos, dir)
			dirty = true
		elseif updated then
			optic_trigger(v.pos, dir, 1)
		end
	end
	if dirty then
		meta:set_string("nc_optics", minetest.serialize(data))
	end

	local hash = minetest.hash_node_position(v.pos)
	local olddep = deprev[hash]
	if olddep then
		for k in pairs(olddep) do
			local t = depidx[k]
			if t then t[hash] = nil end
		end
	end
	for k in pairs(v.deps) do
		local t = depidx[k]
		if not t then
			t = {}
			depidx[k] = t
		end
		t[hash] = true
	end
end

local passive_queue = {}
minetest.register_abm({
		label = "optic check",
		interval = 5,
		chance = 1,
		nodenames = {"group:optic_check"},
		action = function(pos)
			passive_queue[#passive_queue + 1] = pos
		end
	})

local passive_batch = {}
nodecore.register_globalstep("optic check", function()
		local batch = optic_queue
		optic_queue = {}

		if #passive_queue > 0 then
			passive_batch = passive_queue
			passive_queue = {}
			for i = 1, #passive_batch do
				local j = math_random(1, #passive_batch)
				local t = passive_batch[i]
				passive_batch[i] = passive_batch[j]
				passive_batch[j] = t
			end
		end
		local max = 25 - #batch
		if max < 5 then max = 5 end
		if max > #passive_batch then max = #passive_batch end
		for _ = 1, max do
			local pos = passive_batch[#passive_batch]
			passive_batch[#passive_batch] = nil
			batch[minetest.hash_node_position(pos)] = pos
		end

		local trans = {}
		for _, pos in pairs(batch) do
			optic_process(trans, pos)
		end

		for _, v in pairs(trans) do
			optic_commit(v)
		end
	end)

for fn in pairs({
		set_node = true,
		add_node = true,
		remove_node = true,
		swap_node = true,
		dig_node = true,
		place_node = true,
		add_node_level = true
	}) do
	local func = minetest[fn]
	minetest[fn] = function(pos, ...)
		local t = depidx[minetest.hash_node_position(pos)]
		if t then
			for k in pairs(t) do
				optic_check(minetest.get_position_from_hash(k))
			end
		end
		return func(pos, ...)
	end
end
