-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local function dug(n)
	return {true,
		"dig:nc_terrain:" .. n .. "_loose",
		"dig:nc_terrain:" .. n,
		"inv:nc_terrain:" .. n .. "_loose",
		"inv:nc_terrain:" .. n,
	}
end

nodecore.register_hint("dig up dirt",
	dug("dirt")
)

nodecore.register_hint("dig up gravel",
	dug("gravel"),
	"toolcap:crumbly:2"
)

nodecore.register_hint("dig up sand",
	dug("sand")
)

nodecore.register_hint("dig up cobble",
	dug("cobble"),
	"toolcap:cracky:2"
)

nodecore.register_hint("find deep stone strata",
	"group:hard_stone",
	dug("cobble")
)

nodecore.register_hint("find pumwater",
	{true, "group:amalgam", "group:lava"},
	"nc_terrain:cobble_loose"
)

nodecore.register_hint("leach dirt to sand",
	"leach nc_terrain:dirt",
	"dig:nc_terrain:dirt_loose"
)
