-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "hud flags",
		action = function(player, data)
			local interact = nodecore.interact(player)
			data.hud_flags.crosshair = false
			data.hud_flags.wielditem = interact or false
			data.hud_flags.hotbar = interact or false
			data.hud_flags.healthbar = false
			data.hud_flags.breathbar = false
			data.hud_flags.minimap = false
			data.hud_flags.minimap_radar = false
		end
	})
