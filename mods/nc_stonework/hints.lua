-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("put a gravel tip on a wooden adze",
	"assemble graveled adze",
	{"inv:group:gravel", "nc_woodwork:adze"}
)

nc.register_hint("break cobble into chips",
	"break cobble to chips",
	"nc_terrain:cobble_loose"
)

nc.register_hint("pack stone chips back into cobble",
	"repack chips to cobble",
	"nc_stonework:chip"
)

nc.register_hint("put a stone tip onto a wooden tool",
	{true,
		"assemble nc_stonework:tool_mallet",
		"assemble nc_stonework:tool_spade",
		"assemble nc_stonework:tool_hatchet",
		"assemble nc_stonework:tool_pick"
	},
	"nc_stonework:chip"
)

nc.register_hint("chisel stone bricks",
	"chisel bricks",
	{"group:smoothstone", "group:chisel"}
)

nc.register_hint("bond stone bricks",
	"bond bricks",
	"chisel bricks"
)
