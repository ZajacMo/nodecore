-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("make fire by rubbing sticks together",
	"stick fire starting",
	"nc_tree:stick"
)

nodecore.register_hint("find ash",
	"nc_fire:ash",
	"stick fire starting"
)

nodecore.register_hint("find charcoal",
	"group:charcoal",
	"stick fire starting"
)

nodecore.register_hint("chop up charcoal",
	{true,
		"nc_fire:lump_coal",
		"chop nc_fire:coal1",
		"chop nc_fire:coal2",
		"chop nc_fire:coal3",
		"chop nc_fire:coal4",
		"chop nc_fire:coal5",
		"chop nc_fire:coal6",
		"chop nc_fire:coal7",
		"chop nc_fire:coal8"
	},
	"group:charcoal"
)

nodecore.register_hint("pack high-quality charcoal",
	"nc_fire:coal" .. nodecore.fire_max,
	"nc_fire:lump_coal"
)
