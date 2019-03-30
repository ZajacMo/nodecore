-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_size("main", 8)

		player:set_physics_override({speed = 1.25})

		player:set_properties({
				makes_footstep_sound = true,

				-- Allow slight zoom for screenshots
				zoom_fov = 60
			})
	end)
