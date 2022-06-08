-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local function show(player, text, ttl)
	nodecore.hud_set_multiline(player, {
			label = "touchtip",
			hud_elem_type = "text",
			position = {x = 0.5, y = 0.85},
			text = text,
			number = 0xFFFFFF,
			alignment = {x = 0, y = 0},
			offset = {x = 0, y = 0},
			ttl = ttl or 2
		}, nodecore.translate)
end

local wields = {}

nodecore.register_playerstep({
		label = "wield touchtips",
		action = function(player, data)
			if not nodecore.interact(player) then return end
			local wn = nodecore.touchtip_stack(player:get_wielded_item(), true)
			if wn ~= wields[data.pname] then
				wields[data.pname] = wn
				show(player, wn)
			end
		end
	})

nodecore.register_on_joinplayer("touchtip wield reset", function(player)
		local pname = player:get_player_name()
		wields[pname] = nil
	end)
