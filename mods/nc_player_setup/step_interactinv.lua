-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "inventory requires interact",
		action = function(player)
			if nodecore.interact(player) then return end
			return nodecore.inventory_dump(player)
		end
	})
