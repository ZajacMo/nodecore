-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local breath = {}

local function breathimg(br)
	local o = 255 * (1 - br / 11)
	if o == 0 then return "" end
	return "nc_player_hud_breath.png^[opacity:"
	.. math_floor(o)
end

local function sethudflags(player, pname)
	local interact = nodecore.interact(pname or player)
	player:hud_set_flags({
			wielditem = interact or false,
			hotbar = interact or false,
			healthbar = false,
			breathbar = false,
			minimap = false,
			minimap_radar = false
		})
end

local function grantrevoke(pname)
	minetest.after(0, function()
			local player = minetest.get_player_by_name(pname)
			if player then return sethudflags(player, pname) end
		end)
end

minetest.register_on_priv_grant(grantrevoke)
minetest.register_on_priv_revoke(grantrevoke)

minetest.register_on_joinplayer(function(player)
		sethudflags(player)
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("nc_player_hud_bar.png")
		player:hud_set_hotbar_selected_image("nc_player_hud_sel.png")

		if not minetest.settings:get_bool("enable_damage") then
			player:set_breath(11)
		end
		local img = breathimg(player:get_breath())
		breath[player:get_player_name()] = {
			id = player:hud_add({
					hud_elem_type = "image",
					position = {x = 0.5, y = 0.5},
					text = img,
					direction = 0,
					scale = {x = -100, y = -100},
					offset = {x = 0, y = 0}
				}),
			val = img
		}
	end)

local function breathhud(player)
	local hud = breath[player:get_player_name()]
	if not hud then return end
	local i = breathimg(player:get_breath())
	if hud.val == i then return end
	hud.val = i
	return player:hud_change(hud.id, "text", i)
end

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			breathhud(player)
		end
	end)
