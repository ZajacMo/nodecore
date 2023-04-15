-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.unregister_chatcommand("kill")

nodecore.register_on_joinplayer("join setup inv", function(player)
		local inv = player:get_inventory()
		inv:set_size("main", 8)
		inv:set_size("craft", 0)
		inv:set_size("craftpreview", 0)
		inv:set_size("craftresult", 0)

		player:set_properties({
				pointable = false,
				breath_max = 20,
				collisionbox = {
					-0.3,
					-0.0001,
					-0.3,
					0.3,
					1.8,
					0.3
				}
			})
		player:set_lighting({
				exposure = {
					luminance_min = -6,
					luminance_max = -2.5,
					exposure_correction = 0,
					speed_dark_bright = 500,
					speed_bright_dark = 500,
					center_weight_power = 1
				}
			})
	end)

minetest.register_allow_player_inventory_action(function(_, action)
		return action == "move" and 0 or 1000000
	end)
