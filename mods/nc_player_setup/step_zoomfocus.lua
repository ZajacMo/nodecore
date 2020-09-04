-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local zoom_base = 60 * nodecore.rate_adjustment("zoom", "base")
local zoom_ratio = 1 - 1 / (4 * nodecore.rate_adjustment("zoom", "ratio"))
local zoom_time = 2 * nodecore.rate_adjustment("zoom", "time")

nodecore.register_playerstep({
		label = "zoom focus",
		action = function(_, data)
			local ctl = data.control
			local focusing = ctl.sneak and (not ctl.jump) and (not ctl.up)
			and (not ctl.down) and (not ctl.left) and (not ctl.right)
			local zoom = zoom_base
			if focusing and data.zoomfocus then
				zoom = zoom_base - zoom_base * zoom_ratio * (1 - 1 /
					((nodecore.gametime - data.zoomfocus) / zoom_time + 1))
			else
				data.zoomfocus = nodecore.gametime
			end
			local oldzoom = data.properties.zoom_fov or 0
			if oldzoom > (zoom * 1.02) or oldzoom < zoom then
				data.properties.zoom_fov = zoom
			end
		end
	})
