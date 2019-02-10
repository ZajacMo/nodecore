-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, type
    = ItemStack, ipairs, math, minetest, nodecore, pairs, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

local function underride(t, u, v, ...)
	if v then underride(u, v, ...) end
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

function nodecore.dirs()
	return {
		{x = 1, y = 0, z = 0},
		{x = -1, y = 0, z = 0},
		{x = 0, y = 1, z = 0},
		{x = 0, y = -1, z = 0},
		{x = 0, y = 0, z = 1},
		{x = 0, y = 0, z = -1}
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
	for i, v in ipairs(t) do
		max = max - v.w
		if max <= 0 then return v.v, v.k end
	end
end

function nodecore.extend_item(name, func)
	local orig = minetest.registered_items[name]
	local copy = {}
	for k, v in pairs(orig) do copy[k] = v end
	copy = func(copy, orig) or copy
	minetest.register_item(":" .. name, copy)
end

function nodecore.fixedbox(...) return {type = "fixed", fixed = {...}} end

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
						{pos = pos, gain = 0.5})
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
	local def = minetest.registered_nodes[node.name]
	return def and def.groups and def.groups[name]
end

function nodecore.item_eject(pos, stack, speed, qty, vel)
	stack = ItemStack(stack)
	speed = speed or 0
	vel = vel or {x = 0, y = 0, z = 0}
	for i = 1, (qty or 1) do
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
		if obj then obj:setvelocity(v) end
	end
end

function nodecore.quenched(pos)
	return #minetest.find_nodes_in_area(
		{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
		{"group:coolant"}) > 0
end
