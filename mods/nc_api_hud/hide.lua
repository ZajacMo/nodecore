-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc
    = core, ipairs, nc
-- LUALOCALS > ---------------------------------------------------------

local metakey = core.get_current_modname() .. "_hide"

local metacache = {}

core.register_chatcommand("hidehuds", {
		description = "hide groups of HUDs",
		func = function(name, param)
			local player = core.get_player_by_name(name)
			if not player then return false, "must be online" end
			metacache[name] = param
			player:get_meta():set_string(metakey, param)
		end
	})

function nc.hud_hidden(player, group)
	if not group then return end
	local pname = player:get_player_name()
	local hidden = metacache[pname]
	if not hidden then
		hidden = player:get_meta():get_string(metakey) or ""
		metacache[pname] = hidden
	end
	for _, s in ipairs(hidden:split(",")) do
		if group == s then return true end
	end
end
