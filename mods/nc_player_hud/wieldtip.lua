-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

local function show(player, text, ttl)
	nc.hud_set_multiline(player, {
			label = "touchtip",
			hud_elem_type = "text",
			position = {x = 0.5, y = 0.85},
			text = text,
			number = 0xFFFFFF,
			alignment = {x = 0, y = 0},
			offset = {x = 0, y = 0},
			ttl = ttl or 2
		}, nc.translate)
end

local wields = {}
local wieldIndex = {}

nc.register_playerstep({
		label = "wield touchtips",
		action = function(player, data)
			if not nc.interact(player) then return end
			local wn = nc.touchtip_stack(player:get_wielded_item(), true)
			local wi = player:get_wield_index()
			if wn ~= wields[data.pname] or wi ~= wieldIndex[data.pname] then
				wields[data.pname] = wn
				wieldIndex[data.pname] = wi
				show(player, wn)
			end
		end
	})

nc.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		wields[pname] = nil
		wieldIndex[pname] = nil
	end)
