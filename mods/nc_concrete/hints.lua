-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("assemble a stone-tipped stylus",
	"assemble stylus",
	{"nc_tree:stick", "nc_stonework:chip"}
)
nodecore.register_hint("etch pliant concrete with a stylus",
	"stylus etch",
	"assemble stylus"
)
nodecore.register_hint("change a stylus pattern",
	"stylus train",
	"stylus etch"
)

nodecore.register_hint("mix gravel into ash to make aggregate",
	"mix aggregate",
	{"nc_terrain:gravel_loose", "nc_fire:ash"}
)
nodecore.register_hint("mix sand into ash to make render",
	"mix render",
	{"nc_terrain:sand_loose", "nc_fire:ash"}
)
nodecore.register_hint("mix dirt into ash to make adobe mix",
	"mix mud",
	{"nc_terrain:dirt_loose", "nc_fire:ash"}
)
nodecore.register_hint("add coal to aggregate to make tarstone",
	"craft:" .. modname .. ":coalaggregate",
	{"nc_fire:lump_coal", modname .. ":aggregate"}
)

nodecore.register_hint("wet a concrete mix",
	"group:concrete_wet",
	"group:concrete_powder"
)
nodecore.register_hint("set concrete to pliant",
	"group:concrete_etchable",
	"group:concrete_wet"
)
nodecore.register_hint("cure pliant concrete fully",
	"cure pliant concrete",
	"group:concrete_etchable"
)
