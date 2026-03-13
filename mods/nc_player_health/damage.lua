-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local hurtcache = {}

nc.register_on_player_hpchange(function(player, hp)
		local orig = player:get_hp()
		if not nc.player_can_take_damage(player) then
			return orig
		end
		if hp < 0 then
			local pname = player:get_player_name()
			hurtcache[pname] = nc.gametime
			player:get_meta():set_float("hurttime", nc.gametime)
			if nc.player_visible(player) and nc.interact(player) then
				core.after(0, function()
						local now = player:get_hp()
						if now >= orig then return end
						nc.sound_play_except("player_damage", {
								pos = player:get_pos(),
								gain = 0.5
							}, player)
					end)
			end
		end
		if hp + orig <= 0 then
			hp = 1 - orig
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end,
	true
)

nc.register_on_dieplayer(function(player)
		nc.setphealth(player, 0, "on_dieplayer")
	end)

local full = {}
nc.register_playerstep({
		label = "healing",
		action = function(player, data, dtime)
			local pname = data.pname
			local hp = player:get_hp()
			if hp <= 0 then return end
			if hp == 1 then
				local meta = player:get_meta()
				if meta:get_float("dhp") == -1 then
					local hurt = hurtcache[pname] or meta:get_float("hurttime")
					if hurt + 0.5 < nc.gametime then
						nc.setphealth(player, 0, "heal_rehurtfx", 2)
					end
				end
			end
			local hpmax = player:get_properties().hp_max
			if full[pname] and player:get_hp() >= hpmax then return end
			full[pname] = nil
			local hurt = hurtcache[pname] or player:get_meta():get_float("hurttime")
			if hurt >= nc.gametime - 4 then return end
			nc.addphealth(player, dtime * 2, "heal")
			if nc.getphealth(player) >= hpmax then full[pname] = true end
		end
	})

local function setmax(player)
	if nc.player_rejected(player) then return end
	player:set_properties({hp_max = 8})
end
nc.register_on_joinplayer(setmax)
nc.register_on_newplayer(setmax)
