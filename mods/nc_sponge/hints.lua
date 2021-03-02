-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("find a sponge",
	"group:sponge"
)

nodecore.register_hint("harvest a sponge",
	"inv:nc_sponge:sponge_living",
	"group:sponge"
)

nodecore.register_hint("dry out a sponge",
	"nc_sponge:sponge",
	"group:sponge"
)

nodecore.register_hint("squeeze out a sponge",
	"squeeze sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)
