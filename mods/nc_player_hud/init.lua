-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs
    = minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

local health_bar_definition ={
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "nc_player_hud_heart_bg.png",
	number = 20,
	direction = 0,
	size = {x = 24, y = 24},
	offset = { x = (-10 * 24) - 25, y = -(48 + 24 + 16)},
}

local function make_breath_bar(t)
	return {
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "nc_player_hud_bubble_bg.png",
		number = t and 0 or 20,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 25, y = -(48 + 24 + 16)},
	}
end

local function make_wield_bar(x, y, t)
	return {
		hud_elem_type = "text",
		position = {x = 0.5, y = 1},
		text = t or "",
		number = (x == 0 and y == 0) and 0xFFFFFF or 0,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 25 + x, y = -(48 + 24 + 8 - y)},
		alignment = {x = 1, y = 0.5}
	}
end

local huds = {}

local function wield_breath_data(player)
	if player:get_breath() < 11 then return end

	local s = player:get_wielded_item()
	if s:is_empty() then return "" end

	local t = s:get_meta():get_string("description")
	if t and t ~= "" then return t end

	local d = minetest.registered_items[s:get_name()]
	return d and d.description or ""
end

local function dohuds(player)
	local pname = player:get_player_name()

	local val = wield_breath_data(player)

	local hud = huds[pname]
	if not hud then
		huds[pname] = {
			healthid = player:hud_add(health_bar_definition),
			breathid = player:hud_add(make_breath_bar(val)),
			wieldids = {
				player:hud_add(make_wield_bar(-1, 0, val)),
				player:hud_add(make_wield_bar(1, 0, val)),
				player:hud_add(make_wield_bar(0, -1, val)),
				player:hud_add(make_wield_bar(0, 1, val)),
				player:hud_add(make_wield_bar(0, 0, val)),
			},
			val = val
		}
		return
	end

	if val == hud.val then return end
	
	if not val then
		player:hud_change(hud.breathid, "number", 20)
	elseif not hud.val then
		player:hud_change(hud.breathid, "number", 0)
	end
	
	for _, id in pairs(hud.wieldids) do
		player:hud_change(id, "text", val or "")
	end
	
	hud.val = val
end

minetest.register_globalstep(function()
		for _, p in pairs(minetest.get_connected_players()) do
			dohuds(p)
		end
	end)

minetest.register_on_joinplayer(function(player)
		huds[player:get_player_name()] = nil
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("nc_player_hud_bar.png")
		player:hud_set_hotbar_selected_image("nc_player_hud_sel.png")
	end)
