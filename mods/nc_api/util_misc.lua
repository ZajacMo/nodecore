-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, string,
      tonumber, tostring, type, unpack, vector
    = ItemStack, ipairs, math, minetest, nodecore, pairs, string,
      tonumber, tostring, type, unpack, vector
local math_cos, math_log, math_pi, math_random, math_sin, math_sqrt,
      string_gsub, string_lower
    = math.cos, math.log, math.pi, math.random, math.sin, math.sqrt,
      string.gsub, string.lower
-- LUALOCALS > ---------------------------------------------------------

for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

local function underride(t, u, u2, ...)
	if u2 then underride(u, u2, ...) end
	for k, v in pairs(u) do
		if t[k] == nil then
			t[k] = v
		elseif type(t[k]) == "table" and type(v) == "table" then
			underride(t[k], v)
		end
	end
	return t
end
nodecore.underride = underride

function nodecore.mkreg()
	local t = {}
	local f = function(x) t[#t + 1] = x end
	return f, t
end

function nodecore.memoize(func)
	local cache
	return function()
		if cache then return cache[1] end
		cache = {func()}
		return cache[1]
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

function nodecore.pickrand(tbl, weight)
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
	max = math_random() * max
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

function nodecore.interact(player)
	if not player then return end
	if type(player) ~= "string" then
		if not (player.is_player and player:is_player()) then
			return true
		end
		player = player:get_player_name()
	end
	return minetest.get_player_privs(player).interact
end

function nodecore.wieldgroup(who, group)
	local wielded = who and who:get_wielded_item()
	local nodedef = minetest.registered_nodes[wielded:get_name()]
	if nodedef then return nodedef.groups and nodedef.groups[group] end
	local caps = wielded and wielded:get_tool_capabilities()
	return caps and caps.groupcaps and caps.groupcaps[group]
end

function nodecore.toolspeed(what, groups)
	if not what then return end
	local dg = what:get_tool_capabilities().groupcaps
	local t
	for gn, lv in pairs(groups) do
		local gt = dg[gn]
		gt = gt and gt.times
		gt = gt and gt[lv]
		if gt and (not t or t > gt) then t = gt end
	end
	if (not t) and (not what:is_empty()) then
		return nodecore.toolspeed(ItemStack(""), groups)
	end
	return t
end

function nodecore.interval(after, func)
	local function go()
		minetest.after(after, go)
		return func()
	end
	minetest.after(after, go)
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
			if not minetest.settings:get_bool("creative_mode") then
				wielded:add_wear(dp.wear * (qty or 1))
				if wielded:get_count() <= 0 and wdef.sound
				and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks,
						{object = player, gain = 0.5})
				end
			end
		end
		return player:set_wielded_item(wielded)
	end
end

function nodecore.consume_wield(player, qty)
	local wielded = player:get_wielded_item()
	if wielded then
		local wdef = wielded:get_definition()
		if wdef.stack_max > 1 and qty then
			local have = wielded:get_count() - qty
			if have <= 0 then
				wielded = ItemStack("")
			else
				wielded:set_count(have)
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

function nodecore.item_eject(pos, stack, speed, qty, vel)
	stack = ItemStack(stack)
	speed = speed or 0
	vel = vel or {x = 0, y = 0, z = 0}
	if speed == 0 and vel.x == 0 and vel.y == 0 and vel.z == 0
	and nodecore.place_stack and minetest.get_node(pos).name == "air" then
		stack:set_count(stack:get_count() * (qty or 1))
		return nodecore.place_stack(pos, stack)
	end
	for _ = 1, (qty or 1) do
		local v = {
			x = vel.x + (math_random() - 0.5) * speed,
			y = vel.y + math_random() * speed,
			z = vel.z + (math_random() - 0.5) * speed,
		}
		local p = {
			x = v.x > 0 and pos.x + 0.4 or v.x < 0 and pos.x - 0.4 or pos.x,
			y = pos.y + 0.25,
			z = v.z > 0 and pos.z + 0.4 or v.z < 0 and pos.z - 0.4 or pos.z,
		}
		local obj = minetest.add_item(p, stack)
		if obj then obj:set_velocity(v) end
	end
end

do
	local stddirs = {}
	for _, v in pairs(nodecore.dirs()) do
		if v.y <= 0 then stddirs[#stddirs + 1] = v end
	end
	function nodecore.item_disperse(pos, name, qty, outdirs)
		if qty < 1 then return end
		local dirs = {}
		for _, d in pairs(outdirs or stddirs) do
			local p = vector.add(pos, d)
			if nodecore.buildable_to(p) then
				dirs[#dirs + 1] = {pos = p, qty = 0}
			end
		end
		if #dirs < 1 then
			return nodecore.item_eject(pos, name .. " " .. qty)
		end
		for _ = 1, qty do
			local p = dirs[math_random(1, #dirs)]
			p.qty = p.qty + 1
		end
		for _, v in pairs(dirs) do
			if v.qty > 0 then
				nodecore.item_eject(v.pos, name .. " " .. v.qty)
			end
		end
	end
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

function nodecore.node_spin_custom(...)
	local arr = {...}
	arr[0] = false
	local lut = {}
	for i = 1, #arr do
		lut[arr[i - 1]] = arr[i]
	end
	lut[arr[#arr]] = arr[1]
	local qty = #arr

	return function(pos, node, clicker, itemstack)
		node = node or minetest.get_node(pos)
		node.param2 = lut[node.param2] or lut[false]
		if clicker:is_player() then
			minetest.log(clicker:get_player_name() .. " spins "
				.. node.name .. " at " .. minetest.pos_to_string(pos)
				.. " to param2 " .. node.param2 .. " ("
				.. qty .. " total)")
		end
		minetest.swap_node(pos, node)
		nodecore.node_sound(pos, "place")
		local def = minetest.registered_items[node.name] or {}
		if def.on_spin then def.on_spin(pos, node) end
		return itemstack
	end
end
function nodecore.node_spin_filtered(func)
	local rots = {}
	for i = 0, 23 do
		local f = nodecore.facedirs[i]
		local hit
		for j = 1, #rots do
			if not hit then
				local o = nodecore.facedirs[rots[j]]
				hit = hit or func(f, o)
			end
		end
		if not hit then rots[#rots + 1] = f.id end
	end
	return nodecore.node_spin_custom(unpack(rots))
end

function nodecore.node_change(pos, node, newname)
	if node.name == newname then return end
	return minetest.set_node(pos, underride({name = newname}, node))
end

local function scrubkey(s)
	return string_lower(string_gsub(tostring(s), "%W+", "_"))
end

function nodecore.rate_adjustment(...)
	local rate = 1
	local key = scrubkey(nodecore.product)
	for _, k in ipairs({...}) do
		if not k then break end
		key = key .. "_" .. scrubkey(k)
		local adj = tonumber(minetest.settings:get(key))
		if adj then rate = rate * adj end
	end
	return rate
end
