-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp)
		local orig = player:get_hp()
		if player:get_armor_groups().immortal then
			return orig
		end
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
	end,
	true
)

minetest.register_on_dieplayer(function(player)
		player:set_hp(1)
		player:get_meta():set_float("dhp", -1)
	end)

minetest.register_globalstep(function(dtime)
		for _, p in pairs(minetest.get_connected_players()) do
			if p:get_hp() > 0 and p:get_breath() > 10 then
				nodecore.addphealth(p, dtime)
			end
		end
	end)
