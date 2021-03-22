-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, string, tonumber, type,
      vector
    = ipairs, math, minetest, nodecore, pairs, string, tonumber, type,
      vector
local math_floor, math_random, string_format
    = math.floor, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function config(n)
	return minetest.settings:get(nodecore.product:lower()
		.. "_optic_" .. n)
end
local optic_distance = tonumber(config("distance")) or 16
local optic_speed = tonumber(config("speed")) or 12
local optic_tick_limit = tonumber(config("tick_limit")) or 0.2
local optic_interval = tonumber(config("interval")) or 5
local optic_passive_max = tonumber(config("passive_max")) or 25
local optic_passive_min = tonumber(config("passive_max")) or 5

local microtime = minetest.get_us_time
local hashpos = minetest.hash_node_position
local unhash = minetest.get_position_from_hash
local get_node = minetest.get_node
local set_node = minetest.set_node

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
local passive_queue = {}
local dependency_index = {}
local dependency_reverse = {}
local cbb_index = {}
local trigger_cache = {}

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
		if node_opaque[node.name] then return p, node end
		if node_visinv[node.name] then
			local stack = nodecore.stack_get(p)
			if node_opaque[stack:get_name()] then
				return p, node
			end
		end
	end
end

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

local function optic_check(pos)
	optic_queue[hashpos(pos)] = pos
end
nodecore.optic_check = optic_check

local function optic_trigger(start, dir, max, cbbs)
	local pos, node = scan(start, dir, max, get_node, cbbs)
	if node and node_optic_checks[node.name] then
		return optic_check(pos)
	end
end

local function optic_process(trans, pos)
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
		local nn = check(pos, node, recv, getnode)
		if (not ignored) and nn then
			trans[hashpos(pos)] = {
				pos = pos,
				nn = nn,
				deps = deps
			}
		end
	end
end

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
	if (not trigger_cache[vhash]) or node.name ~= nn.name
	or node.param ~= nn.param or nn.param2 ~= nn.param2 then
		set_node(v.pos, nn)
		local src = node_optic_sources[nn.name]
		src = src and src(v.pos, nn)
		local newidx = {}
		if src then
			local cbbs = {}
			cbb_index[vhash] = cbbs
			for _, dir in pairs(src) do
				local hash = hashpos(dir)
				if not (trigger_cache[vhash] and oldidx[hash]) then
					optic_trigger(v.pos, dir, nil, cbbs)
				end
				newidx[hash] = dir
			end
		else
			cbb_index[vhash] = nil
		end
		for hash, dir in pairs(oldidx) do
			if not newidx[hash] then optic_trigger(v.pos, dir) end
		end
		trigger_cache[vhash] = true
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

nodecore.register_limited_abm({
		label = "optic check",
		interval = optic_interval,
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
		for _, pos in pairs(batch) do
			optic_process(trans, pos)
		end

		for _, v in pairs(trans) do
			optic_commit(v)
		end
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
							.. " after running %d cycles in %0.3fs"
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
		local t = dependency_index[hashpos(pos)]
		if t then
			for k in pairs(t) do
				optic_check(unhash(k))
			end
		end
		return func(pos, ...)
	end
end
set_node = minetest.set_node

nodecore.interval(2, function()
		local dedupe = {}
		for _, list in pairs(cbb_index) do
			for i = 1, #list do
				local item = list[i]
				dedupe[minetest.pos_to_string(item.pos, 1)
				.. minetest.pos_to_string(item.plane, 0)] = item
			end
		end
		local players = {}
		for _, p in ipairs(minetest.get_connected_players()) do
			local pos = p:get_pos()
			pos.y = pos.y + p:get_properties().eye_height
			players[#players + 1] = {
				name = p:get_player_name(),
				pos = pos
			}
		end
		for _, item in pairs(dedupe) do
			for i = 1, #players do
				local play = players[i]
				local diff = vector.subtract(item.pos, play.pos)
				if vector.dot(diff, diff) < 64 then
					minetest.add_particlespawner({
							amount = 10,
							time = 2,
							minpos = vector.add(item.pos, vector.multiply(item.plane, -0.1)),
							maxpos = vector.add(item.pos, vector.multiply(item.plane, 0.1)),
							minvel = vector.multiply(item.dir, -0.1),
							maxvel = vector.multiply(item.dir, 0.1),
							minacc = vector.multiply(item.plane, -0.25),
							maxacc = vector.multiply(item.plane, 0.25),
							minsize = 0.25,
							maxsize = 0.5,
							minexptime = 1,
							maxexptime = 2,
							texture = modname .. "_port_output.png",
							playername = play.name
						})
				end
			end
		end
	end)
