-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local minetest = minetest
minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_size("main", 8)
		player:set_inventory_formspec("size[8,1]list[current_player;main;0,0;8,1;]")
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("nc_hud_bg.png")
		player:hud_set_hotbar_selected_image("nc_hud_sel.png")
	end)
