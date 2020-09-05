-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("dig up dirt",
	"dig:nc_terrain:dirt_loose"
)

nodecore.register_hint("dig up gravel",
	"dig:nc_terrain:gravel_loose",
	"toolcap:crumbly:2"
)

nodecore.register_hint("dig up sand",
	"dig:nc_terrain:sand_loose"
)

nodecore.register_hint("dig up stone",
	"dig:nc_terrain:cobble_loose",
	"toolcap:cracky:2"
)

nodecore.register_hint("find deep stone strata",
	"group:hard_stone",
	"nc_terrain:cobble_loose"
)

nodecore.register_hint("find molten rock",
	{true, "group:amalgam", "group:lava"},
	"nc_terrain:cobble_loose"
)

nodecore.register_hint("leach dirt to sand",
	"leach nc_terrain:dirt",
	"dig:nc_terrain:dirt_loose"
)
