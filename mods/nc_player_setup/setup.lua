-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_size("main", 8)

		player:set_properties({
				makes_footstep_sound = true,
				
				-- No-jump stair climbing on all platforms, with
				-- a little extra for climbing up from stack nodes
				stepheight = 1.4,

				-- Allow slight zoom for screenshots
				zoom_fov = 60
			})
	end)
