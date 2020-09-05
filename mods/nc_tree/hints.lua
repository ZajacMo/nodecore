-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("find dry (loose) leaves",
	"nc_tree:leaves_loose"
)

nodecore.register_hint("find an eggcorn",
	"nc_tree:eggcorn"
)

nodecore.register_hint("plant an eggcorn",
	"eggcorn planting",
	{"nc_tree:eggcorn", "nc_terrain:dirt_loose"}
)

nodecore.register_hint("see a tree grow",
	{true,
		"tree growth",
		"nc_tree:tree_bud"
	},
	"eggcorn planting"
)

nodecore.register_hint("find a stick",
	"nc_tree:stick"
)

nodecore.register_hint("cut down a tree",
	"dig:nc_tree:tree",
	"toolcap:choppy:2"
)

nodecore.register_hint("dig up a tree stump",
	"dig:nc_tree:root",
	"toolcap:choppy:4"
)

nodecore.register_hint("grind leaves into peat",
	"nc_tree:peat",
	"nc_tree:leaves_loose"
)

nodecore.register_hint("ferment peat into humus",
	"nc_tree:humus",
	"nc_tree:peat"
)

nodecore.register_hint("leach humus to dirt",
	"leach nc_tree:humus",
	"nc_tree:humus"
)
