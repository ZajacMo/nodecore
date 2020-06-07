-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.unregister_chatcommand("kill")

local function setup(player)
	local inv = player:get_inventory()
	inv:set_size("main", 8)
	inv:set_size("craft", 0)
	inv:set_size("craftpreview", 0)
	inv:set_size("craftresult", 0)

	player:set_properties({
			pointable = false,
			breath_max = 20
		})
end
minetest.register_on_newplayer(function(player)
		setup(player)
		player:set_breath(player:get_properties().breath_max + 1)
	end)
minetest.register_on_joinplayer(setup)

minetest.register_allow_player_inventory_action(function(_, action)
		return action == "move" and 0 or 1000000
	end)
