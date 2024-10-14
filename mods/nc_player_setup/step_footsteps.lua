-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "footsteps",
		action = function(player, data)
			data.properties.makes_footstep_sound
			= nc.player_visible(player)
			and not data.control.sneak
		end
	})
