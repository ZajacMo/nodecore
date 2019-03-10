-- LUALOCALS < ---------------------------------------------------------
local math, minetest, pairs
    = math, minetest, pairs
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

minetest.register_on_joinplayer(function(player)
		player:hud_set_flags({
				healthbar = false,
				breathbar = false
			})
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("nc_player_hud_bar.png")
		player:hud_set_hotbar_selected_image("nc_player_hud_sel.png")

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
	return player:hud_change(hud.id, "text", i)
end

minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			breathhud(player)
		end
	end)
