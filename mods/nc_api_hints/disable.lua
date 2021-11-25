-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.hints_disabled()
	return not nodecore.setting_bool(modname .. "_enable", true, "Enable challenges",
		[[Enable/show the challenge system and all related interfaces. Disabling
		this may be useful on multiplayer servers if the players are all
		experienced and the challenges are obtrusive or distracting.]])
end
