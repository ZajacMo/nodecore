-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local function show(player, text, ttl)
	nodecore.hud_set_multiline(player, {
			label = "touchtip",
			hud_elem_type = "text",
			position = {x = 0.5, y = 0.75},
			text = text,
			number = 0xFFFFFF,
			alignment = {x = 0, y = 0},
			offset = {x = 0, y = 0},
			ttl = ttl or 2
		}, nodecore.translate)
end
nodecore.show_touchtip = show

local countdescs = {"@1"}
for i = 2, 9 do countdescs[i] = "@1 (" .. i .. ")" end
for j = 10, 90, 10 do
	for i = 0, 9 do
		countdescs[j + i] = "@1 (" .. j .. "@2)"
	end
end
countdescs[100] = "@1 (100@2)"
for i = 2, #countdescs do nodecore.translate_inform(countdescs[i]) end
local plus = nodecore.translate("+")

local weardescs = {"@1"}
for i = 1, 65535 do
	local q = math_floor(i * 5 / 65536 + 0.5)
	local t = "@1 "
	for _ = 1, (5 - q) do t = t .. "|" end
	for _ = 1, q do t = t .. "." end
	weardescs[i] = t
	nodecore.translate_inform(weardescs[i])
end

local function stack_desc(s, noqty)
	if s:is_empty() then return "" end

	local n = s:get_name()
	local d = minetest.registered_items[n] or {}

	local t = s:get_meta():get_string("description")
	t = t ~= "" and t or d.description or n

	if not noqty then
		local c = s:get_count()
		if c > 1 then
			t = nodecore.translate(t)
			local cd = countdescs[c > 100 and 100 or c]
			if c >= 10 then
				t = nodecore.translate(cd, t, c >= s:get_stack_max() and "" or plus)
			else
				t = nodecore.translate(cd, t)
			end
		else
			local w = s:get_wear()
			if w > 1 then
				t = nodecore.translate(t)
				t = nodecore.translate(weardescs[w], t)
			end
		end
	end

	if d.on_stack_touchtip then
		return d.on_stack_touchtip(s, t) or t
	end
	return t
end
nodecore.touchtip_stack = stack_desc

local function node_desc(pos, node, puncher, pointed, ...)
	if pointed and pointed.above and pointed.under
	and vector.equals(pos, pointed.under) then
		local anode = minetest.get_node(pointed.above)
		local def = minetest.registered_items[anode.name] or {}
		if def.on_node_touchthru then
			return def.on_node_touchthru(pointed.above,
				anode, pointed.under, puncher, ...)
		end
	end

	node = node or minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_items[name] or {}
	if def.air_equivalent or def.pointable == false then return end

	local metaname = minetest.get_meta(pos):get_string("description")
	if metaname and metaname ~= "" then
		name = metaname
	elseif def.groups and def.groups.is_stack_only then
		name = stack_desc(nodecore.stack_get(pos))
	elseif def.description then
		name = def.description
	end

	if def.groups and def.groups.visinv and not def.groups.is_stack_only then
		local s = nodecore.stack_get(pos)
		local t = stack_desc(s)
		if t and t ~= "" then name = name .. "\n" .. t end
	end

	if def.on_node_touchtip then
		return def.on_node_touchtip(pos, node, name, puncher, pointed, ...) or name
	end
	return name
end
nodecore.touchtip_node = node_desc

local wields = {}

nodecore.register_playerstep({
		label = "wield touchtips",
		action = function(player)
			local pname = player:get_player_name()
			local wn = stack_desc(player:get_wielded_item(), true)
			if wn ~= wields[pname] then
				wields[pname] = wn
				show(player, wn)
			end
		end
	})

nodecore.register_on_punchnode("touchtip on punch", function(pos, node, puncher, ...)
		return show(puncher, node_desc(pos, node, puncher, ...))
	end)

nodecore.register_on_joinplayer("touchtip wield reset", function(player)
		local pname = player:get_player_name()
		wields[pname] = nil
	end)
