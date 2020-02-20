-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

minetest.register_on_player_hpchange(function(player, hp, reason)
		local orig = player:get_hp()
		if reason and reason.type == "drown" then hp = hp * 2 end
		if player:get_armor_groups().immortal then
			return orig
		end
		if hp < 0 then
			player:get_meta():set_float("hurttime", nodecore.gametime)
			if nodecore.player_visible(player) then
				minetest.after(0, function()
						local now = player:get_hp()
						if now >= orig then return end
						nodecore.sound_play_except("player_damage", {
								pos = player:get_pos(),
								gain = 0.5
							}, player)
					end)
			end
		end
		if hp + orig <= 0 then
			hp = 2 - orig
			player:get_meta():set_float("dhp", -2)
			local pname = player:get_player_name()
			minetest.after(0, function()
					player = minetest.get_player_by_name(pname)
					if player then return nodecore.addphealth(player, 0) end
				end)
		end
		return hp
	end,
	true
)

minetest.register_on_dieplayer(function(player)
		player:set_hp(1)
		player:get_meta():set_float("dhp", -1)
	end)

local full = {}
local function heal(player, dtime)
	local hpmax = player:get_properties().hp_max
	if player:get_hp() <= 0 then return end
	if player:get_breath() <= 0 then return end
	local pname = player:get_player_name()
	if full[pname] and player:get_hp() >= hpmax then return end
	full[pname] = nil
	local hurt = player:get_meta():get_float("hurttime")
	if hurt >= nodecore.gametime - 4 then return end
	nodecore.addphealth(player, dtime * 2)
	if nodecore.getphealth(player) >= hpmax then full[pname] = true end
end
minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			heal(player, dtime)
		end
	end)

minetest.register_on_joinplayer(function(player)
		player:set_properties({hp_max = 8})
	end)
