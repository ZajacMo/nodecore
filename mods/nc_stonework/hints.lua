-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("put a gravel tip on a wooden adze",
	"assemble graveled adze",
	{"inv:group:gravel", "nc_woodwork:adze"}
)

nodecore.register_hint("break cobble into chips",
	"break cobble to chips",
	"nc_terrain:cobble_loose"
)

nodecore.register_hint("pack stone chips back into cobble",
	"repack chips to cobble",
	"nc_stonework:chip"
)

nodecore.register_hint("put a stone tip onto a wooden tool",
	{true,
		"assemble nc_stonework:tool_mallet",
		"assemble nc_stonework:tool_spade",
		"assemble nc_stonework:tool_hatchet",
		"assemble nc_stonework:tool_pick"
	},
	"nc_stonework:chip"
)

nodecore.register_hint("chisel stone bricks",
	"chisel bricks",
	{"group:smoothstone", "group:chisel"}
)

nodecore.register_hint("bond stone bricks",
	"bond bricks",
	"chisel bricks"
)
