-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, vector
    = ipairs, minetest, vector
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		if hp < 0 then
			local pos = player:get_pos()
			for _, p in ipairs(minetest.get_connected_players()) do
				if p ~= player and vector.distance(p:get_pos(), pos) <= 32 then
					minetest.sound_play("player_damage", {
							to_player = p:get_player_name(),
							pos = pos,
							gain = 0.5
						})
				end
			end
		end
		local t = player:get_hp()
		if hp + t <= 0 then
			hp = 1 - t
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end, true)
