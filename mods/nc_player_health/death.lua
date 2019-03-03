-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_dieplayer(function(player)		
		local inv = player:get_inventory()
		local pos = player:getpos()
		for i = 1, inv:get_size("main") do
			nodecore.item_eject(pos, inv:get_stack("main", i), 10)
		end
		inv:set_list("main", {})
		player:set_attribute("dhp", "0")
	end)

minetest.register_on_respawnplayer(function(player)
		nodecore.setphealth(player, 0.0001)
	end)
