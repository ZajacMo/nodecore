-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "hud flags",
		action = function(player, data)
			local interact = nodecore.interact(player)
			data.hud_flags.crosshair = false
			data.hud_flags.wielditem = (not nodecore.hud_hidden(player, "wield"))
			and interact or false
			data.hud_flags.hotbar = (not nodecore.hud_hidden(player, "hotbar"))
			and interact or false
			data.hud_flags.healthbar = false
			data.hud_flags.breathbar = false
			data.hud_flags.minimap = false
			data.hud_flags.minimap_radar = false
		end
	})
