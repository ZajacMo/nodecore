-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, type, vector
    = math, minetest, nodecore, pairs, type, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local node_optic_checks = {}
local node_optic_sources = {}
local node_opaque = {}
local node_visinv = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			node_optic_checks[k] = v.optic_check or nil
			node_optic_sources[k] = v.optic_source or nil
			node_opaque[k] = (not v.sunlight_propagates) or nil
			node_visinv[k] = v.groups and v.groups.visinv or nil
		end
	end)

local optic_queue = {}

local function scan(pos, dir, max, deps)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	if (not max) or (max > 16) then max = 16 end
	for _ = 1, max do
		p = vector.add(p, dir)
		if deps then deps[minetest.hash_node_position(p)] = true end
		local node = minetest.get_node(p)
		if node.name == "ignore" then return false, node end
		if node_opaque[node.name] then return p, node end
		if node_visinv[node.name] then
			local stack = nodecore.stack_get(p)
			if node_opaque[stack:get_name()] then
				return p, node
			end
		end
	end
end

local function scan_recv(pos, dir, deps)
	local hit, node = scan(pos, dir, nil, deps)
	if not hit then return hit, node end
	local src = node_optic_sources[node.name]
	src = src and src(hit, node)
	if not src then return end
	local rev = vector.multiply(dir, -1)
	for _, v in pairs(src) do
		if vector.equals(v, rev) then
			return hit, node
		end
	end
end

local function optic_check(pos)
	optic_queue[minetest.hash_node_position(pos)] = pos
end
nodecore.optic_check = optic_check

local function optic_trigger(start, dir, max)
	local pos, node = scan(start, dir, max)
	if not node then return end
	if node_optic_checks[node.name] then return optic_check(pos) end
end

local function optic_process(trans, pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then return end

	local ignored
	local check = node_optic_checks[node.name]
	if check then
		local deps = {}
		local func = function(dir)
			local hit, hnode = scan_recv(pos, dir, deps)
			ignored = ignored or hit == false
			return hit, hnode
		end
		local nn = check(pos, node, func)
		if (not ignored) and nn then
			trans[minetest.hash_node_position(pos)] = {
				pos = pos,
				nn = nn,
				deps = deps
			}
		end
	end
end

local depidx = {}
local deprev = {}

local function optic_commit(v)
	local node = minetest.get_node(v.pos)

	local oldidx = {}
	local oldsrc = node_optic_sources[node.name]
	oldsrc = oldsrc and oldsrc(v.pos, node)
	if oldsrc then
		for _, dir in pairs(oldsrc) do
			oldidx[minetest.hash_node_position(dir)] = dir
		end
	end

	local nn = v.nn
	if type(nn) == "string" then nn = {name = nn} end
	nn.param = nn.param or node.param
	nn.param2 = nn.param2 or node.param2
	if node.name ~= nn.name or node.param ~= nn.param or nn.param2 ~= nn.param2 then
		minetest.set_node(v.pos, nn)
		local src = node_optic_sources[nn.name]
		src = src and src(v.pos, nn)
		local newidx = {}
		if src then
			for _, dir in pairs(src) do
				local hash = minetest.hash_node_position(dir)
				if not oldidx[hash] then optic_trigger(v.pos, dir) end
				newidx[hash] = dir
			end
		end
		for hash, dir in pairs(oldidx) do
			if not newidx[hash] then optic_trigger(v.pos, dir) end
		end
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
nodecore.register_limited_abm({
		label = "optic check",
		interval = 5,
		chance = 1,
		nodenames = {"group:optic_check"},
		action = function(pos)
			passive_queue[#passive_queue + 1] = pos
		end
	})
nodecore.register_lbm({
		name = modname .. ":check",
		run_at_every_load = true,
		nodenames = {"group:optic_check"},
		action = optic_check
	})

local passive_batch = {}
local function optic_check_pump()
	local batch = optic_queue
	optic_queue = {}

	if nodecore.stasis then
		passive_queue = {}
		return
	end

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
end

do
	local tick = 1/12
	local total = 0
	nodecore.register_globalstep("optic check", function(dtime)
			total = total + dtime / tick
			if total > 10 then total = 10 end
			while total > 1 do
				optic_check_pump()
				total = total - 1
			end
		end)
end

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
