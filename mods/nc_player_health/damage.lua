-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local hurtcache = {}

nodecore.register_on_player_hpchange("damage modifier", function(player, hp)
		local orig = player:get_hp()
		if not nodecore.player_can_take_damage(player) then
			return orig
		end
		if hp < 0 then
			local pname = player:get_player_name()
			hurtcache[pname] = nodecore.gametime
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
			hp = 1 - orig
			player:get_meta():set_float("dhp", -1)
		end
		return hp
	end,
	true
)

nodecore.register_on_dieplayer("player virtual 0 health", function(player)
		nodecore.setphealth(player, 0, "on_dieplayer")
	end)

local full = {}
nodecore.register_playerstep({
		label = "healing",
		action = function(player, data, dtime)
			local pname = data.pname
			local hp = player:get_hp()
			if hp <= 0 then return end
			if hp == 1 then
				local meta = player:get_meta()
				if meta:get_float("dhp") == -1 then
					local hurt = hurtcache[pname] or meta:get_float("hurttime")
					if hurt + 0.5 < nodecore.gametime then
						nodecore.setphealth(player, 0, "heal_rehurtfx", 2)
					end
				end
			end
			local hpmax = player:get_properties().hp_max
			if full[pname] and player:get_hp() >= hpmax then return end
			full[pname] = nil
			local hurt = hurtcache[pname] or player:get_meta():get_float("hurttime")
			if hurt >= nodecore.gametime - 4 then return end
			nodecore.addphealth(player, dtime * 2, "heal")
			if nodecore.getphealth(player) >= hpmax then full[pname] = true end
		end
	})

local function setmax(player)
	player:set_properties({hp_max = 8})
end
nodecore.register_on_joinplayer("set max health on join", setmax)
nodecore.register_on_newplayer("set max health on new", setmax)
