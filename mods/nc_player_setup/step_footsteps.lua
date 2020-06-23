-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "footsteps",
		action = function(player, data)
			data.properties.makes_footstep_sound
			= nodecore.player_visible(player)
			and not data.control.sneak
		end
	})
