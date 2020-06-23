-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs
    = nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "inventory requires interact",
		action = function(player, data)
			if nodecore.interact(player) then return end
			local pos = player:get_pos()
			pos.y = pos.y + data.properties.eye_height
			local inv = player:get_inventory()
			for i, stack in pairs(inv:get_list("main")) do
				if not stack:is_empty() then
					if nodecore.item_is_virtual(stack) then
						nodecore.item_eject(pos, stack, 0.001)
						inv:set_stack("main", i, "")
					end
				end
			end
		end
	})
