-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, pairs, string
    = ipairs, minetest, pairs, string
local string_sub
    = string.sub
-- LUALOCALS > ---------------------------------------------------------

local health_bar_definition = {
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

local font_chars = {}
local font_size
do
	local s = "`1234567890-=qwertyuiop[]\\asdfghjkl;'zxcvbnm,./"
	.. "~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:\"ZXCVBNM<>?"
	font_size = #s
	for i = 1, #s do
		font_chars[string_sub(s, i, i)] = i - 1
	end
end

local function wield_char(s, n)
	if (not s) or (n > #s) then return "" end
	n = font_chars[string_sub(s, n, n)]
	if not n then return "" end
	return "nc_player_hud_font.png^[verticalframe:"
	.. font_size .. ":" .. n
end

local function make_wield_bar(x, t)
	return {
		hud_elem_type = "image",
		position = {x = 0.5, y = 1},
		scale = {x = 1, y = 1},
		text = t or "",
		offset = {x = 25 + x * 11 - 2, y = -(48 + 24 + 16)},
		alignment = {x = 1, y = 1}
	}
end

local huds = {}

local function wield_breath_data(player)
	if player:get_breath() < 11 then return end

	local s = player:get_wielded_item()
	if s:is_empty() then return "" end

	local t = s:get_meta():get_string("description")
	if t and t ~= "" then return t end

	local n = s:get_name()
	local d = minetest.registered_items[n]
	return d and d.description or n
end

local function dohuds(player)
	local pname = player:get_player_name()

	local val = wield_breath_data(player)

	local hud = huds[pname]
	if not hud then
		local w = {}
		for i = 1, 30 do
			w[i] = player:hud_add(make_wield_bar(i - 1, wield_char(val, i)))
		end
		huds[pname] = {
			healthid = player:hud_add(health_bar_definition),
			breathid = player:hud_add(make_breath_bar(val)),
			wieldids = w,
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

	for i, id in ipairs(hud.wieldids) do
		local o = wield_char(hud.val, i)
		local n = wield_char(val, i)
		if n ~= o then
			player:hud_change(id, "text", n)
		end
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
