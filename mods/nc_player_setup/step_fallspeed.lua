-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "terminal velocity",
		action = function(player, data)
			data.physics.gravity = nc.grav_air_physics_player(
				player:get_velocity())
		end
	})
