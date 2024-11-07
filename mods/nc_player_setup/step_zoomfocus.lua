-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

local zoom_base = 60
local zoom_ratio = 3/4
local zoom_time = 2

nc.register_playerstep({
		label = "zoom focus",
		action = function(_, data)
			local ctl = data.control
			local focusing = ctl.zoom and (not ctl.sneak) and (not ctl.aux1)
			and (not ctl.jump) and (not ctl.up) and (not ctl.down)
			and (not ctl.left) and (not ctl.right)
			local zoom = zoom_base
			if focusing and data.zoomfocus then
				local zoomqty = nc.gametime - data.zoomfocus - 2
				if zoomqty < 0 then zoomqty = 0 end
				zoom = zoom_base - zoom_base * zoom_ratio * (1 - 1 /
					(zoomqty / zoom_time + 1))
			else
				data.zoomfocus = nc.gametime
			end
			local oldzoom = data.properties.zoom_fov or 0
			if oldzoom > (zoom * 1.02) or oldzoom < zoom then
				data.properties.zoom_fov = zoom
			end
		end
	})
