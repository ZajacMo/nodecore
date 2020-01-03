-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local cached = {}
minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local g = nodecore.grav_air_physics_player(player:get_player_velocity())
			local og = cached[pname]
			if g ~= og then
				player:set_physics_override({gravity = g})
				cached[pname] = g
			end
		end
	end)

minetest.register_on_leaveplayer(function(player)
		cached[player:get_player_name()] = nil
	end)
