-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("find lux",
	"group:lux_rock",
	"toolcap:cracky:2"
)

nc.register_hint("dig up lux cobble",
	"inv:group:lux_cobble",
	{"group:lux_rock", "toolcap:cracky:2"}
)

nc.register_hint("observe a lux reaction",
	"group:lux_hot",
	"inv:group:lux_cobble"
)

nc.register_hint("observe lux criticality",
	"group:lux_cobble_max",
	"group:lux_hot"
)

nc.register_hint("lux-infuse a lode tool",
	"group:lux_tool",
	"group:lux_cobble_max"
)
