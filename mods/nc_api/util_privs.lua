-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local warned
function nc.get_player_privs_cached(...)
	if not warned then
		nc.log("warning", "deprecated nc.get_player_privs_cached(...)")
		warned = true
	end
	return core.get_player_privs(...)
end

function nc.interact(player)
	return not player or core.get_player_privs(player).interact
end
