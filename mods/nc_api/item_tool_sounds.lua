-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_on_register_item(function(_, def)
		if def.type == "tool" then
			def.sound = def.sound or {}
			def.sound.breaks = def.sound.breaks or {name = "nc_api_toolbreak", gain = 1}
		end
	end)
