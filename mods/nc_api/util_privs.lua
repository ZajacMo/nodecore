-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local warned
function nodecore.get_player_privs_cached(...)
	if not warned then
		nodecore.log("warning", "deprecated nodecore.get_player_privs_cached(...)")
		warned = true
	end
	return minetest.get_player_privs(...)
end

function nodecore.interact(player)
	return not player or minetest.get_player_privs(player).interact
end
