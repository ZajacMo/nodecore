-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		local t = player:get_hp()
		if hp + t <= 0 then
			hp = 1 - t
			player:set_attribute("dhp", "-1")
		end
		return hp
	end, true)

minetest.register_on_dieplayer(function(player)		
		local inv = player:get_inventory()
		local pos = player:getpos()
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			local def = minetest.registered_items[stack:get_name()]
			if def and not def.destroy_on_death then
				nodecore.item_eject(pos, stack, 5)
			end
		end
		inv:set_list("main", {})
		player:set_attribute("dhp", "0")
	end)

minetest.register_on_respawnplayer(function(player)
		nodecore.setphealth(player, 0.0001)
	end)
