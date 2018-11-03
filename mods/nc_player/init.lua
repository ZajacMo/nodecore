-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_joinplayer(function(player)
		player:set_properties({
				visual = "upright_sprite",
				visual_size = { x = 1, y = 2 },
				textures = { "nc_player_front.png", "nc_player_back.png" },
			})

		player:get_inventory():set_size("main", 8)
		player:hud_set_hotbar_itemcount(8)

		player:hud_set_hotbar_image("nc_hud_bg.png")
		player:hud_set_hotbar_selected_image("nc_hud_sel.png")

		player:set_inventory_formspec("size[8,1]"
			.. "bgcolor[#000000C0;true]"
			.. "background[0,0;8,1;nc_player_invbg.png;true]"
			.. "listcolors[#00000000;#00000000;#00000000]"
			.. "list[current_player;main;0,0;8,1;]")
	end)
