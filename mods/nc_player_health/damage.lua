-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		local orig = player:get_hp()
		if hp < 0 then
			minetest.after(0, function()
					local now = player:get_hp()
					if now >= orig then return end
					nodecore.sound_play_except("player_damage", {
							pos = player:get_pos(),
							gain = 0.5
							}, player)
				end)
		end
		if hp + orig <= 0 then
			hp = 1 - orig
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end, true)
