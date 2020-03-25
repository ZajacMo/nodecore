-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.unregister_chatcommand("kill")

minetest.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		inv:set_size("main", 8)
		inv:set_size("craft", 0)
		inv:set_size("craftpreview", 0)
		inv:set_size("craftresult", 0)

		player:set_physics_override({speed = 1.25})

		nodecore.ent_prop_set(player, {
				pointable = false,
				makes_footstep_sound = true,

				-- Allow slight zoom for screenshots
				zoom_fov = 60
			})
	end)

minetest.register_allow_player_inventory_action(function(_, action)
		return action == "move" and 0 or 1000000
	end)
