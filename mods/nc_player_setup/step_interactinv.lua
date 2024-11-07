-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "inventory requires interact",
		action = function(player)
			if nc.interact(player) then return end
			return nc.inventory_dump(player)
		end
	})
