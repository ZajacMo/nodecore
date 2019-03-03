-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_size("main", 8)
		player:set_properties({stepheight = 1.2})
	end)
