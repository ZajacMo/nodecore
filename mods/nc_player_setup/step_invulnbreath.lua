-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "invulnerable breath",
		action = function(player, data)
			if (not nc.player_can_take_damage(player))
			and player:get_breath() < data.properties.breath_max then
				player:set_breath(data.properties.breath_max)
			end
		end
	})
