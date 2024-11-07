-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_hint("quench pumwater to amalgamation",
	"group:amalgam",
	{true, "group:amalgam", "group:lava"}
)

nc.register_hint("find pumice",
	modname .. ":pumice",
	{true, "group:amalgam", "group:lava"}
)

nc.register_hint("harden stone",
	"stone hardened",
	"group:lava"
)

nc.register_hint("weaken stone by soaking",
	"stone softened",
	"group:lava"
)

nc.register_hint("melt stone into pumwater",
	"stone melted",
	"group:lava"
)
