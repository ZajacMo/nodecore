-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.hints_disabled()
	return not nodecore.setting_bool(modname .. "_enable", true, "Enable discovery system",
		[[Enable/show the discovery system and all related interfaces. Disabling
		this may be useful on multiplayer servers if the players are all
		experienced and the discoveries are obtrusive or distracting.]])
end

nodecore.hints_disabled() -- for startup settingtypes.txt
