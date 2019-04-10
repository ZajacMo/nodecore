-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest
    = ipairs, minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		for _, l in ipairs(inv:get_lists()) do
			inv:set_size(l, l == "main" and 8 or 0)
		end

		player:set_physics_override({speed = 1.25})

		player:set_properties({
				makes_footstep_sound = true,

				-- Allow slight zoom for screenshots
				zoom_fov = 60
			})
	end)

minetest.register_allow_player_inventory_action(function(_, action)
		return action == "move" and 0 or 1000000
	end)
