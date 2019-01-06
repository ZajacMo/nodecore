-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, next, nodecore, pairs, table, type
    = ipairs, math, minetest, next, nodecore, pairs, table, type
local math_random, table_insert
    = math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

function nodecore.mkreg()
	local t = {}
	local f = function(x) t[#t + 1] = x end
	return f, t
end

local node_is_skip = {name = true, param2 = true, param = true, groups = true}
function nodecore.node_is(node_or_pos, match)
	if not node_or_pos.name then
		local p = { }
		for k, v in pairs(minetest.get_node(node_or_pos)) do
			p[k] = v
		end
		for k, v in pairs(node_or_pos) do
			p[k] = v
		end
		node_or_pos = p
	end
	while type(match) == "function" do
		match = match(node_or_pos)
		if not match then return end
		if match == true then return node_or_pos end
	end
	if type(match) == "string" then match = {name = match} end
	if match.name and node_or_pos.name ~= match.name then return end
	if match.param2 and node_or_pos.param2 ~= match.param2 then return end
	if match.param and node_or_pos.param ~= match.param then return end
	local def = minetest.registered_nodes[node_or_pos.name]
	if match.groups then
		if not def.groups then return end
		for k, v in match.groups do
			if v == true then
				if not def.groups[k] then return end
			else
				if def.groups[k] ~= v then return end
			end
		end
	end
	for k, v in pairs(match) do
		if not node_is_skip[k] then
			if def[k] ~= v then return end
		end
	end
	return node_or_pos
end
function nodecore.buildable_to(node_or_pos)
	return nodecore.node_is(node_or_pos, {buildable_to = true})
end

function nodecore.pickrand(tbl, weight)
	weight = weight or function() end
	local t = {}
	local max = 0
	for k, v in pairs(tbl) do
		local w = weight(v) or 1
		if w > 0 then
			max = max + w
			t[#t + 1] = {w = w, v = v}
		end
	end
	if max <= 0 then return end
	max = math_random() * max
	for i, v in ipairs(t) do
		max = max - v.w
		if max <= 0 then return v.v end
	end
end

function nodecore.extend_item(name, func)
	local orig = minetest.registered_items[name]
	local copy = {}
	for k, v in pairs(orig) do copy[k] = v end
	copy = func(copy, orig) or copy
	minetest.register_item(":" .. name, copy)
end
nodecore.extend_node = nodecore.extend_item

function nodecore.fixedbox(...) return {type = "fixed", fixed = {...}} end

function nodecore.wieldgroup(who, group)
	local wielded = who and who:get_wielded_item()
	local caps = wielded and wielded:get_tool_capabilities()
	return caps and caps.groupcaps and caps.groupcaps[group]
end

local dirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
}
function nodecore.scan_flood(pos, range, func)
	local q = {pos}
	local seen = { }
	for d = 0, range do
		local next = {}
		for i, p in ipairs(q) do
			local res = func(p)
			if res then return res end
			if res == nil then
				for k, v in pairs(dirs) do
					local np = {
						x = p.x + v.x,
						y = p.y + v.y,
						z = p.z + v.z
					}
					local nk = minetest.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table_insert(next, np)
					end
				end
			end
		end
		if #next < 1 then break end
		for i = 1, #next do
			local j = math_random(1, #next)
			next[i], next[j] = next[j], next[i]
		end
		q = next
	end
end

function nodecore.interval(after, func)
	local function go()
		minetest.after(after, go)
		return func()
	end
	minetest.after(after, go)
end

function nodecore.wear_current_tool(player, groups, qty)
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
		player:set_wielded_item(wielded)
	end
end
