-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		local t = player:get_hp()
		if hp + t <= 0 then
			hp = 1 - t
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end, true)
