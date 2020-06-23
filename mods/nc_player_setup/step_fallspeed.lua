-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "terminal velocity",
		action = function(player, data)
			data.physics.gravity = nodecore.grav_air_physics_player(
				player:get_player_velocity())
		end
	})
