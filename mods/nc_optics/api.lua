-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, string, type, vector
    = error, math, minetest, nodecore, pairs, string, type, vector
local math_floor, math_random, string_format
    = math.floor, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local optic_distance = nodecore.setting_float(modname .. "_optic_distance", 16,
	"Optic beam distance", [[WARNING: FUNDAMENTAL CONSTANT. Maximum distance
	from which an optic beam can be sensed by an optic node's input face.
	Changing this may fundamentally alter the game, including making your
	builds incompatible across hosts.]])
local optic_speed = nodecore.setting_float(modname .. "_optic_speed", 12,
	"Optic tick rate", [[WARNING: FUNDAMENTAL CONSTANT. Rate in Hz of
	optic ticks. Changing this may fundamentally alter the game, including
	making your builds incompatible across hosts.]])
local optic_tick_limit = nodecore.setting_float(modname .. "_tick_limit", 0.2,
	"Optic tick limit", [[Maximum amount of time in seconds that may be
	spent during a single server step to calculate optic state. Optics
	will be allowed to slow don to stay within this limit.]])
local optic_interval = nodecore.setting_float(modname .. "_interval", 5,
	"Optic check interval", [[ABM interval for periodically pushing
	optics into the "passive" queue.
	Passive checks are used to catch optics in an inconsistent state, e.g.
	that missed their change event.]])
local optic_passive_max = nodecore.setting_float(modname .. "_passive_max", 25,
	"Optic check passive max", [[The maximum number of optics that can be
	queued in a single pass for "passive" checks to run; pending passive
	checks will be included to fill up remaining spaces up to this total.
	Passive checks are used to catch optics in an inconsistent state, e.g.
	that missed their change event.]])
local optic_passive_min = nodecore.setting_float(modname .. "_passive_min", 5,
	"Optic check passive min", [[The minimum number of "passive" optic
	checks that are run each cycle, overriding the max if needed.
	Passive checks are used to catch optics in an inconsistent state, e.g.
	that missed their change event.]])

local microtime = minetest.get_us_time
local hashpos = minetest.hash_node_position
local unhash = minetest.get_position_from_hash
local get_node = minetest.get_node

local node_optic_checks = {}
local node_optic_sources = {}
local node_opaque = {}
local node_visinv = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			node_optic_checks[k] = v.optic_check or nil
			node_optic_sources[k] = v.optic_source or nil
			node_visinv[k] = v.groups and v.groups.visinv or nil

			local grp_t = minetest.get_item_group(k, "optic_transparent") ~= 0
			local grp_o = minetest.get_item_group(k, "optic_opaque") ~= 0
			if (grp_t and grp_o) then
				error("node cannot be BOTH optic_opaque and optic_transparent")
			end
			node_opaque[k] = grp_o or (not (grp_t or v.sunlight_propagates)) or nil
		end
	end)

local optic_queue = {}
local passive_queue = {}
local dependency_index = {}
local dependency_reverse = {}

local function mapblock(pos)
	return {
		x = math_floor((pos.x + 0.5) / 16),
		y = math_floor((pos.y + 0.5) / 16),
		z = math_floor((pos.z + 0.5) / 16),
	}
end

local function scan(pos, dir, max, getnode, cbbs)
	local p = pos
	if (not max) or (max > optic_distance) then max = optic_distance end
	for _ = 1, max do
		local o = p
		p = vector.add(p, dir)

		if cbbs and not vector.equals(mapblock(o), mapblock(p)) then
			cbbs[#cbbs + 1] = {
				pos = vector.add(o, vector.multiply(dir, 0.5)),
				dir = dir,
				plane = {
					x = dir.x == 0 and 1 or 0,
					y = dir.y == 0 and 1 or 0,
					z = dir.z == 0 and 1 or 0,
				}
			}
		end
		local node = getnode(p)
		if (not node) or node.name == "ignore" then return end
		if node_opaque[node.name] and not node_visinv[node.name] then return p, node end
		if node_visinv[node.name] then
			if node_opaque[node.name] then
				local def = minetest.registered_nodes[node.name] or {}
				if not def.storebox_access then return p, node end
				-- check that “light” can come in from the old position by checking for access
				if not def.storebox_access(
					{above = o, under = p}, p, {}) then return p, node end
				-- check that “light” can go out: this should be checked after checking
				-- if the content is opaque, but we're going to return the same p, node anyway
				-- so it doesn't really matter
				if not def.storebox_access(
					{above = vector.add(p, dir), under = p}, p, {}) then return p, node end
			end
			local stack = nodecore.stack_get(p)
			if node_opaque[stack:get_name()] then
				return p, node
			end
		end
	end
end
nodecore.optic_scan = scan

local function scan_recv(pos, dir, max, getnode)
	local hit, node = scan(pos, dir, max, getnode)
	if not node then return end
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
nodecore.optic_scan_recv = scan_recv

local function optic_check(pos)
	optic_queue[hashpos(pos)] = pos
end
nodecore.optic_check = optic_check

local function optic_trigger(start, dir, max)
	local pos, node = scan(start, dir, max, get_node)
	if node and node_optic_checks[node.name] then
		return optic_check(pos)
	end
end

local function optic_process(trans, pos, defer)
	local node = get_node(pos)
	if node.name == "ignore" then return end

	local check = node_optic_checks[node.name]
	if check then
		local ignored
		local deps = {}
		local getnode = function(p)
			local gn = get_node(p)
			deps[hashpos(p)] = true
			ignored = ignored or gn.name == "ignore"
			return gn
		end
		local recv = function(dir, max)
			return scan_recv(pos, dir, max, getnode)
		end
		local nn = check(pos, node, recv, getnode, defer)
		if (not ignored) and nn then
			trans[hashpos(pos)] = {
				pos = pos,
				nn = nn,
				deps = deps
			}
		end
	end
end

local mkdefer = function()
	local list = {}
	return function(f)
		list[#list + 1] = f
	end,
	function()
		for i = 1, #list do (list[i])() end
	end
end

local function optic_immediate(pos)
	local trans = {}
	local defer, finish = mkdefer()
	optic_process(trans, pos, defer)
	for _, v in pairs(trans) do
		if vector.equals(v.pos, pos) then
			local node = get_node(pos)
			if v.nn ~= node.name then
				node.name = v.nn
				nodecore.set_node(pos, node)
			end
			break
		end
	end
	finish()
	return optic_check(pos)
end
nodecore.optic_immediate = optic_immediate

local function optic_commit(v)
	local node = get_node(v.pos)

	local oldidx = {}
	local oldsrc = node_optic_sources[node.name]
	oldsrc = oldsrc and oldsrc(v.pos, node)
	if oldsrc then
		for _, dir in pairs(oldsrc) do
			oldidx[hashpos(dir)] = dir
		end
	end

	local nn = v.nn
	if type(nn) == "string" then nn = {name = nn} end
	nn.param = nn.param or node.param
	nn.param2 = nn.param2 or node.param2
	local vhash = hashpos(v.pos)
	if node.name ~= nn.name or node.param ~= nn.param or node.param2 ~= nn.param2 then
		local odef = minetest.registered_nodes[node.name] or {}
		local ndef = minetest.registered_nodes[nn.name] or {}
		if odef.nc_optic_family ~= ndef.nc_optic_family then
			nodecore.log("warning", string_format(
					"optic_commit tried to replace %s with %s at %s",
					node.name, nn.name, minetest.pos_to_string(v.pos)))
			return
		end

		minetest.set_node(v.pos, nn)
		local src = node_optic_sources[nn.name]
		src = src and src(v.pos, nn)
		local newidx = {}
		if src then
			for _, dir in pairs(src) do
				local hash = hashpos(dir)
				if not oldidx[hash] then
					optic_trigger(v.pos, dir)
				end
				newidx[hash] = dir
			end
		end
		for hash, dir in pairs(oldidx) do
			if not newidx[hash] then optic_trigger(v.pos, dir) end
		end
	end

	local olddep = dependency_reverse[vhash]
	if olddep then
		for k in pairs(olddep) do
			local t = dependency_index[k]
			if t then t[vhash] = nil end
		end
	end
	for k in pairs(v.deps) do
		local t = dependency_index[k]
		if not t then
			t = {}
			dependency_index[k] = t
		end
		t[vhash] = true
	end
end

minetest.register_abm({
		label = "optic check",
		interval = optic_interval,
		chance = 1,
		nodenames = {"group:optic_check"},
		action = function(pos)
			passive_queue[#passive_queue + 1] = pos
		end
	})
nodecore.register_lbm({
		name = modname .. ":optic_check",
		run_at_every_load = true,
		nodenames = {"group:optic_check"},
		action = optic_check
	})

local optic_check_pump
do
	local passive_batch = {}
	optic_check_pump = function()
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
		local max = optic_passive_max - #batch
		if max < optic_passive_min then max = optic_passive_min end
		if max > #passive_batch then max = #passive_batch end
		for _ = 1, max do
			local pos = passive_batch[#passive_batch]
			passive_batch[#passive_batch] = nil
			batch[hashpos(pos)] = pos
		end

		local trans = {}
		local defer, finish = mkdefer()
		for _, pos in pairs(batch) do
			optic_process(trans, pos, defer)
		end
		for _, v in pairs(trans) do
			optic_commit(v)
		end
		finish()
	end
end

do
	local tick = 1 / optic_speed
	local total = 0
	nodecore.register_globalstep("optic tick", function(dtime)
			total = total + dtime / tick
			local starttime = microtime()
			local exp = starttime + optic_tick_limit * 1000000
			local starttotal = total
			while total > 1 do
				optic_check_pump()
				if microtime() >= exp then
					nodecore.log("warning", string_format("optics stopped"
							.. " after running %d cycle(s) in %0.3fs"
							.. ", behind %0.2f",
							starttotal - total,
							(microtime() - starttime) / 1000000,
							total))
					total = 0
				else
					total = total - 1
				end
			end
		end)
end

local function optic_check_dependents(pos)
	local t = dependency_index[hashpos(pos)]
	if t then
		for k in pairs(t) do
			optic_check(unhash(k))
		end
	end
end
nodecore.optic_check_dependents = optic_check_dependents
nodecore.register_on_nodeupdate(optic_check_dependents)
