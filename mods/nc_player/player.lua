-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local version = nodecore.version
version = version and ("Version " .. version) or "DEVELOPMENT VERSION"

nodecore.inventory_formspec = "size[8,5]"
.. "bgcolor[#000000C0;true]"
.. "background[0,0;8,5;nc_player_invbg.png;true]"
.. "listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
.. "list[current_player;main;0,4;8,5;]"
.. "box[-0.25,-0.25;8.5,3.25;#000000C0]"
.. "label[0,0;NodeCore - "
.. minetest.formspec_escape(version)
.. "\n\n"
.. "(C)2018-2019 by Aaron Suen <warr1024@gmail.com>\n"
.. "MIT License:  http://www.opensource.org/licenses/MIT\n\n"
.. "GitLab:    https://gitlab.com/sztest/nodecore\n"
.. "Discord:   https://discord.gg/SHq2tkb]"

minetest.register_on_joinplayer(function(player)
		player:set_properties({
				visual = "upright_sprite",
				visual_size = { x = 1, y = 2 },
				textures = { "nc_player_front.png", "nc_player_back.png" }
			})

		player:get_inventory():set_size("main", 8)
		player:hud_set_hotbar_itemcount(8)

		player:hud_set_hotbar_image("nc_hud_bg.png")
		player:hud_set_hotbar_selected_image("nc_hud_sel.png")

		player:set_inventory_formspec(nodecore.inventory_formspec)
		
		player:set_properties({stepheight = 1.2})
	end)

minetest.register_on_dieplayer(function(player)
		local inv = player:get_inventory()
		local pos = player:getpos()

		for i = 1, inv:get_size("main") do
			nodecore.item_eject(pos, inv:get_stack("main", i), 10)
		end
		inv:set_list("main", {})
	end)
