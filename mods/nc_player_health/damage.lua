-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		if hp < 0 then
			nodecore.sound_play_except("player_damage", {
					pos = player:get_pos(),
					gain = 0.5
					}, player)
		end
		local t = player:get_hp()
		if hp + t <= 0 then
			hp = 1 - t
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end, true)
