-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

function nc.hints_disabled()
	return nc.setting_bool(modname .. "_disable", false, "Discovery system - disable",
		[[Disable/hide the discovery system and all related interfaces. Disabling
		this may be useful on multiplayer servers if the players are all
		experienced and the discoveries are obtrusive or distracting.]])
end

nc.hints_disabled() -- for startup settingtypes.txt
