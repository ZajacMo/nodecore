-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string
    = minetest, nodecore, pairs, string
local string_gmatch, string_rep
    = string.gmatch, string.rep
-- LUALOCALS > ---------------------------------------------------------

local tips = {}

local function show(player, text, ttl)
	local pname = player:get_player_name()
	local tip = tips[pname]
	if not tip then
		tips[pname] = {text = text or "", ttl = ttl or 2}
		return
	end
	tip.text = text or ""
	tip.ttl = ttl or 2
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

local function stack_desc(s)
	if s:is_empty() then return "" end

	local n = s:get_name()
	local d = minetest.registered_items[n] or {}

	local t = s:get_meta():get_string("description")
	t = t ~= "" and t or d.description or n

	local c = s:get_count()
	if c > 1 then
		local cd = countdescs[c > 100 and 100 or c]
		if c >= 10 then
			t = nodecore.translate(cd, t, c >= s:get_stack_max() and "" or plus)
		else
			t = nodecore.translate(cd, t)
		end
	end

	if d.on_stack_touchtip then
		return d.on_stack_touchtip(s, t) or t
	end
	return t
end
nodecore.touchtip_stack = stack_desc

local function node_desc(pos, node)
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
		return def.on_node_touchtip(pos, node, name) or name
	end
	return name
end
nodecore.touchtip_node = node_desc

local wields = {}

local function commit(player, pname, dtime)
	local tip = tips[pname]
	if not tip then return end

	tip.ttl = tip.ttl - dtime
	if tip.ttl <= 0 then tip.text = "" end

	if tip.shown == tip.text then return end

	local lines = {}
	for str in string_gmatch(tip.text, "[^\r\n]+") do
		lines[#lines + 1] = nodecore.translate(str)
	end
	for i = 1, #lines do
		lines[i] = string_rep(" \n", i - 1) .. lines[i]
		.. string_rep("\n ", #lines - i)
	end

	tip.lines = tip.lines or {}
	for i = 1, #lines do
		local old = tip.lines[i]
		if not old then
			tip.lines[i] = {
				id = player:hud_add({
						hud_elem_type = "text",
						position = {x = 0.5, y = 0.75},
						text = lines[i],
						number = 0xFFFFFF,
						alignment = {x = 0, y = 0},
						offset = {x = 0, y = 0},
					}),
				text = lines[i]
			}
		elseif old.text ~= lines[i] then
			player:hud_change(old.id, "text", lines[i])
			old.text = lines[i]
		end
	end

	for i = #tip.lines, #lines + 1, -1 do
		local id = tip.lines[i].id
		player:hud_change(id, "text", "")
		minetest.after(0, function() player:hud_remove(id) end)
		tip.lines[i] = nil
	end

	tip.shown = tip.text
end

minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()

			local wn = stack_desc(player:get_wielded_item())
			if wn ~= wields[pname] then
				wields[pname] = wn
				show(player, wn)
			end

			commit(player, pname, dtime)
		end
	end)

minetest.register_on_punchnode(function(pos, node, puncher)
		return show(puncher, node_desc(pos, node))
	end)

minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		tips[pname] = nil
		wields[pname] = nil
	end)
