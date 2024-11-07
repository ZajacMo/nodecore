-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("make fire by rubbing sticks together",
	"stick fire starting",
	"nc_tree:stick"
)

nc.register_hint("find ash",
	"nc_fire:ash",
	"stick fire starting"
)

nc.register_hint("find charcoal",
	"group:charcoal",
	"stick fire starting"
)

nc.register_hint("chop up charcoal",
	{true,
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

nc.register_hint("pack high-quality charcoal",
	"compress coal block",
	"nc_fire:lump_coal"
)
