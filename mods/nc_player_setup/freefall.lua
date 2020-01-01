-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs
    = minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

-- Terminal velocity = 50m/s, reasonable based on Wikipedia
local friction = 0.0004

local cached = {}
minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local v = player:get_player_velocity()
			v = v.y < 0 and -v.y or 0
			local g = 1 - friction * v * v
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
