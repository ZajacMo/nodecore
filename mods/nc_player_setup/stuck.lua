-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

minetest.register_chatcommand("stuck", {
		description = "Teleport to get unstuck (but you can't bring your items)",
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end

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

			nodecore.setphealth(player, 0)

			pos.x = pos.x + math_random() * 64 - 32
			pos.y = pos.y + math_random() * 64
			pos.z = pos.z + math_random() * 64 - 32
			player:setpos(pos)
		end
	})
