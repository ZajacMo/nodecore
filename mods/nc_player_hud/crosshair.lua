-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local function crosshair(player, fade)
	nodecore.hud_set(player, {
			label = "crosshair",
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			text = "nc_player_hud_crosshair.png^[opacity:"
			.. (fade and 32 or 192),
			direction = 0,
			alignment = {x = 0, y = 0},
			scale = {x = 1, y = 1},
			offset = {x = 0, y = 0},
			z_index = -275,
			quick = true
		})
end

nodecore.register_playerstep({
		label = "crosshair",
		priority = -101,
		action = function(player, data)
			local pt = data.raycast()
			if pt then
				if pt.type == "node" and nodecore.within_map_limits(pt.under) then
					local llu = nodecore.get_node_light(pt.under) or 0
					local lla = nodecore.get_node_light(pt.above) or 0
					local ll = (llu > lla) and llu or lla
					return crosshair(player, ll <= 0)
				elseif pt.type == "object" then
					local ll = nodecore.get_node_light(pt.ref:get_pos()) or 0
					return crosshair(player, ll <= 0)
				end
			end
			return crosshair(player, true)
		end
	})
