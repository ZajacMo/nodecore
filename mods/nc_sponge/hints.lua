-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("find a sponge",
	"group:sponge",
	{true,
		"anim_swim_up",
		"anim_swim_down",
		"anim_swim_mine"
	}
)

nc.register_hint("harvest a sponge",
	"inv:nc_sponge:sponge_living",
	"group:sponge"
)

nc.register_hint("dry out a sponge",
	"nc_sponge:sponge",
	"group:sponge"
)

nc.register_hint("squeeze out a sponge",
	"squeeze sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)
