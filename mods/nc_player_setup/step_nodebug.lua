-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_playerstep({
		label = "disallow basic debug",
		action = function(_, data)
			data.hud_flags = data.hud_flags or {}
			data.hud_flags.basic_debug = false
		end
	})
