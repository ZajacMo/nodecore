-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("find lux",
	"group:lux_emit"
)

nodecore.register_hint("dig up lux cobble",
	"inv:group:lux_cobble",
	"group:lux_emit"
)

nodecore.register_hint("observe a lux reaction",
	"group:lux_hot",
	"inv:group:lux_cobble"
)

nodecore.register_hint("observe lux criticality",
	"group:lux_cobble_max",
	"group:lux_hot"
)

nodecore.register_hint("lux-infuse a lode tool",
	"group:lux_tool",
	"group:lux_cobble_max"
)
