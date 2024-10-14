-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "stepheight",
		action = function(_, data)
			data.properties.stepheight = data.control.sneak and 0.001 or 1.05
		end
	})
