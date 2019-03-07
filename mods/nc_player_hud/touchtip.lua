-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local tips = {}

local function show(player, text, ttl)
	ttl = ttl or 2
	local pname = player:get_player_name()
	local tip = tips[pname]
	if tip then
		if text ~= tip.text then
			player:hud_change(tip.id, "text", text)
			tip.text = text
		end
		tip.ttl = ttl
		return
	end
	tips[pname] = {
		id = player:hud_add({
				hud_elem_type = "text",
				position = {x = 0.5, y = 0.75},
				text = text,
				number = 0xFFFFFF,
				alignment = {x = 0, y = 0},
				offset = { x = 0, y = 0},
			}),
		text = text,
		ttl = ttl
	}
end
nodecore.show_touchtip = show

local wields = {}

local function stack_desc(s)
	if s:is_empty() then return "" end

	local t = s:get_meta():get_string("description")
	if t and t ~= "" then return t end

	local n = s:get_name()
	local d = minetest.registered_items[n]
	return d and d.description or n
end

local function wield_name(player)
	return stack_desc( player:get_wielded_item())
end

minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()

			local wn = wield_name(player)
			if wn ~= wields[pname] then
				wields[pname] = wn
				show(player, wn)
			end

			local tip = tips[pname]
			if tip then
				tip.ttl = tip.ttl - dtime
				if tip.ttl <= 0 then
					player:hud_remove(tip.id)
					tips[pname] = nil
				end
			end
		end
	end)

minetest.register_on_punchnode(function(pos, node, puncher)
		node = node or minetest.get_node(pos)
		local name = node.name
		local def = minetest.registered_items[name]
		if def and def.groups and def.groups.is_stack_only then
			name = stack_desc(nodecore.stack_get(pos))
		elseif def and def.description then
			name = def.description
		end

		show(puncher, name)
	end)

minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		tips[pname] = nil
		wields[pname] = nil
	end)
