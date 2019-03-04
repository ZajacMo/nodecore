-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs
    = minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

local health_bar_definition =
{
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "nc_player_hud_heart_bg.png",
	number = 20,
	direction = 0,
	size = {x = 24, y = 24},
	offset = { x = (-10 * 24) - 25, y = -(48 + 24 + 16)},
}

local breath_bar_definition =
{
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "nc_player_hud_bubble_bg.png",
	number = 0,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y = -(48 + 24 + 16)},
}

local wield_bar_definition =
{
	hud_elem_type = "text",
	position = {x = 0.5, y = 1},
	text = "",
	number = 0xFFFFFF,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y = -(48 + 24 + 8)},
	alignment = {x = 1, y = 0.5}
}

local huds = {}

local function dohuds(player)
	local pname = player:get_player_name()
	local hud = huds[pname]
	if not hud then
		huds[pname] = {
			healthid = player:hud_add(health_bar_definition),
			breathid = player:hud_add(breath_bar_definition),
			wieldid = player:hud_add(wield_bar_definition)
		}
		return
	end

	if player:get_breath() < 11 then
		if hud.val ~= true then
			hud.val = true
			player:hud_change(hud.breathid, "number", 20)
			player:hud_change(hud.wieldid, "text", "")
		end
		return
	end
	if hud.val == true then
		player:hud_change(hud.breathid, "number", 0)
		hud.val = nil
	end

	local t
	local s = player:get_wielded_item()
	if s and (not s:is_empty()) then
		t = s:get_meta():get_string("description")
		if t == "" then
			local d = minetest.registered_items[s:get_name()]
			t = d and d.description
		end
	end
	t = t or ""
	if t ~= hud.val then
		hud.val = t
		player:hud_change(hud.wieldid, "text", t)
	end
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
