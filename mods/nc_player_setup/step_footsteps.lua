-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "footsteps",
		action = function(_, data)
			data.properties.makes_footstep_sound = not data.control.sneak
		end
	})
