-- LUALOCALS < ---------------------------------------------------------
local ItemStack, PcgRandom, error, ipairs, math, minetest, next,
      nodecore, pairs, string, type, vector
    = ItemStack, PcgRandom, error, ipairs, math, minetest, next,
      nodecore, pairs, string, type, vector
local math_abs, math_cos, math_floor, math_log, math_pi, math_pow,
      math_random, math_sin, math_sqrt, string_format, string_sub
    = math.abs, math.cos, math.floor, math.log, math.pi, math.pow,
      math.random, math.sin, math.sqrt, string.format, string.sub
-- LUALOCALS > ---------------------------------------------------------

for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

local function deepcopy(src, mapping)
	if type(src) ~= "table" then return src end

	mapping = mapping or {}
	local found = mapping[src]
	if found then return found end

	local t = {}
	mapping[src] = t
	for k, v in pairs(src) do
		t[k] = deepcopy(v, mapping)
	end

	return t
end
nodecore.deepcopy = deepcopy

local function underride(t, u, u2, ...)
	if u2 then underride(u, u2, ...) end
	for k, v in pairs(u) do
		if t[k] == nil then
			t[k] = deepcopy(v)
		elseif type(t[k]) == "table" and type(v) == "table" then
			underride(t[k], v)
		end
	end
	return t
end
nodecore.underride = underride

--[[--
Converts a complex/mixed list into a flat hashset.
Accepted input values:
- "key" (or other non-nil scalar)
- an array like {"key1", "key2"}
- a hashset like {key1 = true, key2 = true} (values ignored)
- mixed array like {key1 = true, "key2"}
- non-cyclical nesting like {{key1 = true} = true, "key2", {"key3"}}
all nil values are ignored
--]]--
local function flatkeys(list, addto)
	addto = addto or {}
	if list == nil then return end
	if type(list) ~= "table" then
		addto[list] = true
		return addto
	end
	for k in pairs(list) do
		k = type(k) == "number" and list[k] or k
		if k ~= nil then flatkeys(k, addto) end
	end
	return addto
end
nodecore.flatkeys = flatkeys

function nodecore.mkreg()
	local t = {}
	local f = function(x) t[#t + 1] = x end
	return f, t
end

function nodecore.fairlimit(max)
	local queue = {}
	local qty = 0
	local function add(item)
		qty = qty + 1
		if qty > max then
			local id = math_random(1, qty)
			if id <= max then
				queue[id] = item
			end
		else
			queue[qty] = item
		end
	end
	local function flush()
		local batch = queue
		queue = {}
		qty = 0
		return batch
	end
	return add, flush
end

function nodecore.memoize(func)
	local cachedval
	local cached
	return function()
		if cached then return cachedval end
		cachedval = func()
		cached = true
		return cachedval
	end
end

function nodecore.dirs()
	return {
		{n = "e", x = 1, y = 0, z = 0},
		{n = "w", x = -1, y = 0, z = 0},
		{n = "u", x = 0, y = 1, z = 0},
		{n = "d", x = 0, y = -1, z = 0},
		{n = "n", x = 0, y = 0, z = 1},
		{n = "s", x = 0, y = 0, z = -1}
	}
end

function nodecore.vector_to_dir(p)
	local ax = math_abs(p.x)
	local ay = math_abs(p.y)
	local az = math_abs(p.z)
	return ay > ax and ay > az
	and vector.new(0, p.y < 0 and -1 or 1, 0)
	or ax > az
	and vector.new(p.x < 0 and -1 or 1, 0, 0)
	or vector.new(0, 0, p.z < 0 and -1 or 1)
end

function nodecore.pickrand(tbl, weight, rng)
	weight = weight or function() end
	local t = {}
	local max = 0
	for k, v in pairs(tbl) do
		local w = weight(v) or 1
		if w > 0 then
			max = max + w
			t[#t + 1] = {w = w, k = k, v = v}
		end
	end
	if max <= 0 then return end
	max = (rng or math_random)() * max
	for _, v in ipairs(t) do
		max = max - v.w
		if max <= 0 then return v.v, v.k end
	end
end

do
	local saved
	function nodecore.boxmuller()
		local old = saved
		if old then
			saved = nil
			return old
		end
		local r = math_sqrt(-2 * math_log(math_random()))
		local t = 2 * math_pi * math_random()
		saved = r * math_sin(t)
		return r * math_cos(t)
	end
end

function nodecore.exporand(mean, rng)
	local r = 0
	while r == 0 do r = (rng or math_random)() end
	return math_floor(-math_log(r) * (mean + 0.5))
end

function nodecore.seeded_rng(seed)
	if PcgRandom then
		seed = math_floor((seed - math_floor(seed)) * 2 ^ 32 - 2 ^ 31)
		local pcg = PcgRandom(seed)
		return function(a, b)
			if b then
				return pcg:next(a, b)
			elseif a then
				return pcg:next(1, a)
			end
			return (pcg:next() + 2 ^ 31) / 2 ^ 32
		end
	end
	return math_random
end

function nodecore.extend_item(name, func)
	local orig = minetest.registered_items[name] or {}
	local copy = {}
	for k, v in pairs(orig) do copy[k] = v end
	copy = func(copy, orig) or copy
	minetest.register_item(":" .. name, copy)
end

function nodecore.fixedbox(x, ...)
	return {type = "fixed", fixed = {
			x or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			...
	}}
end

function nodecore.player_visible(player)
	if type(player) == "string" then player = minetest.get_player_by_name(player) end
	if not player then return end
	local props = player:get_properties()
	local vs = props and props.visual_size
	return vs and vs.x > 0 and vs.y > 0
end

function nodecore.wieldgroup(who, group)
	local wielded = who and who:get_wielded_item()
	local nodedef = minetest.registered_nodes[wielded:get_name()]
	if nodedef then return nodedef.groups and nodedef.groups[group] end
	local caps = wielded and wielded:get_tool_capabilities()
	return caps and caps.groupcaps and caps.groupcaps[group]
end

function nodecore.interval(after, func)
	local go
	local setnext = (type(after) == "function")
	and function() return minetest.after(after(), go) end
	or function() return minetest.after(after, go) end
	go = function() setnext() return func() end
	minetest.after(0, go)
end

function nodecore.wear_wield(player, groups, qty)
	local wielded = player:get_wielded_item()
	if wielded then
		local wdef = wielded:get_definition()
		local tp = wielded:get_tool_capabilities()
		local dp = minetest.get_dig_params(groups, tp)
		if wdef and wdef.after_use then
			wielded = wdef.after_use(wielded, player, nil, dp) or wielded
		else
			wielded:add_wear(dp.wear * (qty or 1))
			if wielded:get_count() <= 0 and wdef.sound
			and wdef.sound.breaks then
				nodecore.sound_play(wdef.sound.breaks,
					{object = player, gain = 0.5})
			end
		end
		return player:set_wielded_item(wielded)
	end
end

function nodecore.consume_wield(player, qty)
	local wielded = player:get_wielded_item()
	if wielded and qty and qty > 0 then
		local wdef = wielded:get_definition()
		if wdef and wdef.stack_max > 1 then
			local have = wielded:get_count() - qty
			if have <= 0 then
				wielded = ItemStack("")
			else
				wielded:set_count(have)
			end
		elseif wdef and wdef.type == "tool" then
			local uses = 1
			local caps = wielded:get_tool_capabilities()
			for _, v in pairs(caps and caps.groupcaps or {}) do
				if v.uses > uses then uses = v.uses end
			end
			wielded:add_wear_by_uses(uses)
			if wielded:get_count() <= 0 and wdef.sound
			and wdef.sound.breaks then
				nodecore.sound_play(wdef.sound.breaks,
					{object = player, gain = 0.5})
			end
		end
		return player:set_wielded_item(wielded)
	end
end

function nodecore.loaded_mods()
	local t = {}
	for _, v in pairs(minetest.get_modnames()) do
		t[v] = true
	end
	return t
end

function nodecore.node_group(name, pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name] or {}
	return def.groups and def.groups[name]
end

function nodecore.find_nodes_around(pos, spec, r, s)
	r = r or 1
	if type(r) == "number" then
		return minetest.find_nodes_in_area(
			{x = pos.x - r, y = pos.y - r, z = pos.z - r},
			{x = pos.x + r, y = pos.y + r, z = pos.z + r},
			spec)
	end
	s = s or r
	return minetest.find_nodes_in_area(
		{x = pos.x - (r.x or r[1]), y = pos.y - (r.y or r[2]), z = pos.z - (r.z or r[3])},
		{x = pos.x + (s.x or s[1]), y = pos.y + (s.y or s[2]), z = pos.z + (s.z or s[3])},
		spec)
end
function nodecore.quenched(pos, r)
	local qty = #nodecore.find_nodes_around(pos, "group:coolant", r)
	return (qty > 0) and qty or nil
end

local gravity = 9.81
local friction = 0.0004

local function air_accel_factor(v)
	local q = (friction * v * v) * 2 - 1
	return q > 0 and q or 0
end
function nodecore.grav_air_physics_player(v)
	if v.y > 0 then return 1 end
	return 1 - air_accel_factor(v.y)
end
local function air_accel_net(v)
	return v == 0 and 0 or v / -math_abs(v) * gravity * air_accel_factor(v)
end
function nodecore.grav_air_accel(v)
	return {
		x = air_accel_net(v.x),
		y = air_accel_net(v.y) - gravity,
		z = air_accel_net(v.z)
	}
end
function nodecore.grav_air_accel_ent(obj)
	local cur = obj:get_acceleration()
	local new = nodecore.grav_air_accel(obj:get_velocity())
	if vector.equals(cur, new) then return end
	return obj:set_acceleration(new)
end

function nodecore.get_depth_light(y, qty)
	qty = qty or 4/5
	if y < 0 then qty = qty * math_pow(2, y / 64) end
	return qty
end

nodecore.light_sun = 15
nodecore.light_sky = math_floor(0.5 + nodecore.light_sun * nodecore.get_depth_light(0))

function nodecore.is_full_sun(pos)
	return pos.y >= 0 and minetest.get_node_light(pos, 0.5) == nodecore.light_sun
end

function nodecore.is_max_light(pos)
	if nodecore.is_full_sun(pos) then return true end
	local ll = minetest.get_node_light(pos, 0)
	return ll and ll >= 11
end

function nodecore.get_node_light(pos)
	local artificial = minetest.get_node_light(pos, 0)
	if not artificial then return end
	local natural = math_floor(0.5 + minetest.get_node_light(pos, 0.5)
		* nodecore.get_depth_light(pos.y))
	return artificial > natural and artificial or natural
end

local liquids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.liquidtype and v.liquidtype ~= "none" then
				liquids[k] = v
			end
		end
	end)
nodecore.registered_liquids = liquids
local player_was_swimming = {}
function nodecore.player_swimming(player)
	local pname = player:get_player_name()
	local pos = player:get_pos()
	local r = 0.6
	local swimming = true
	for dz = -r, r, r do
		for dx = -r, r, r do
			local p = {
				x = pos.x + dx,
				y = pos.y,
				z = pos.z + dz
			}
			local node = minetest.get_node(p)
			if (node.name == "air" or liquids[node.name]) then
				p.y = p.y - 0.35
				node = minetest.get_node(p)
			end
			if node.name == "air" then swimming = nil
			elseif not liquids[node.name] then
				player_was_swimming[pname] = nil
				return
			end
		end
	end
	if swimming then
		player_was_swimming[pname] = true
		return true
	end
	return player_was_swimming[pname]
end

local function mismatch(a, b, exact)
	if type(a) == "table" then
		if type(b) ~= "table" then return true end
		for k, v in pairs(a) do
			if string_sub(k, 1, 1) ~= "_"
			and mismatch(v, b[k], exact)
			then return true end
		end
		return
	end
	if (not exact) and type(a) == "number" and type(b) == "number" then
		local ratio = a / b
		-- Floating point rounding...
		if ratio > 0.99999 and ratio < 1.00001 then return end
	end
	return a ~= b
end
nodecore.prop_mismatch = mismatch

local grp = "group:"
local function would_match(name, def, itemnames)
	if not (name and def) then return end
	if itemnames == true or not itemnames then return itemnames end
	if name == itemnames then return true end
	local namestype = type(itemnames)
	if namestype == "string" then
		if string_sub(itemnames, 1, #grp) == grp then
			local gn = string_sub(itemnames, #grp + 1)
			return def and def.groups and def.groups[gn] and def.groups[gn] > 0
		end
		return name == itemnames
	elseif namestype == "table" then
		for i = 1, #itemnames do
			if would_match(name, def, itemnames[i]) then
				return true
			end
		end
	else
		error("invalid would_match type " .. namestype)
	end
end
nodecore.would_match = would_match

local function group_expand(itemnames, deferred)
	local deffunc = type(deferred) == "function" and deferred or nil
	local idx = {}
	local function populate()
		while true do
			local k = next(idx)
			if not k then break end
			idx[k] = nil
		end
		for k, v in pairs(minetest.registered_items) do
			if would_match(k, v, itemnames) then
				idx[k] = true
				if deffunc then deffunc(k, idx) end
			end
		end
	end
	populate()
	if deferred then minetest.after(0, populate) end
	return idx
end
nodecore.group_expand = group_expand

function nodecore.item_matching_index(items, getnames, idxname, asarray, keymod)
	local index = {}
	local function itemadd(key, item)
		local t = index[key]
		if not t then
			t = {}
			index[key] = t
		end
		if asarray then
			t[#t + 1] = item
		else
			t[item] = true
		end
	end
	keymod = keymod or function(x) return x end
	local report_pending
	local function rebuild()
		for k in pairs(index) do index[k] = nil end
		for _, item in pairs(items) do
			for k in pairs(nodecore.group_expand(getnames(item))) do
				itemadd(keymod(k, item), item)
			end
		end
		if idxname and not report_pending then
			report_pending = true
			minetest.after(0, function()
					report_pending = nil
					local keys = 0
					local defs = 0
					local peak = 0
					for _, v in pairs(index) do
						keys = keys + 1
						local n = 0
						for _ in pairs(v) do n = n + 1 end
						defs = defs + n
						if n > peak then peak = n end
					end
					nodecore.log("info", string_format(
							"%s %s: %d keys, %d defs, %d peak",
							"item_matching_index",
							idxname, keys, defs, peak))
				end)
		end
	end
	minetest.after(0, rebuild)
	return index, rebuild
end

function nodecore.protection_test(pos, player)
	if not player then return end
	if type(player) ~= "string" then
		if not player:is_player() then return end
		player = player:get_player_name()
	end
	if minetest.is_protected(pos, player) then
		minetest.record_protection_violation(pos, player)
		return true
	end
end

function nodecore.protection_bypass(func, ...)
	local oldprot = minetest.is_protected
	local function helper(...)
		minetest.is_protected = oldprot
		return ...
	end
	function minetest.is_protected() end
	return helper(func(...))
end

function nodecore.meta_serializable(meta)
	local mt = type(meta)
	if mt == "table" or mt == "userdata" then
		if type(meta.to_table) == "function" then
			meta = meta:to_table()
		end
		for _, list in pairs(meta.inventory or {}) do
			for i, stack in pairs(list) do
				if type(stack) == "userdata" then
					list[i] = stack:to_string()
				end
			end
		end
	end
	return meta
end

function nodecore.set_node_check(pos, node, old)
	old = old or minetest.get_node(pos)
	if node.name == old.name and (node.param == nil
		or node.param == old.param) and (node.param2 == nil
		or node.param2 == old.param2) then return end
	return minetest.set_node(pos, node)
end
