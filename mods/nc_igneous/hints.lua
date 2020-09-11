-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("quench pumwater to amalgamation",
	"group:amalgam",
	{true, "group:amalgam", "group:lava"}
)

nodecore.register_hint("find pumice",
	modname .. ":pumice",
	{true, "group:amalgam", "group:lava"}
)

nodecore.register_hint("harden stone",
	"stone hardened",
	"group:lava"
)

nodecore.register_hint("weaken stone by soaking",
	"stone softened",
	"group:lava"
)
