-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("dig leaves",
	"dig:nc_tree:leaves"
)

nc.register_hint("find dry (loose) leaves",
	"nc_tree:leaves_loose",
	"dig:nc_tree:leaves"
)

nc.register_hint("find an eggcorn",
	"nc_tree:eggcorn",
	"dig:nc_tree:leaves"
)

nc.register_hint("plant an eggcorn",
	"eggcorn planting",
	{"inv:nc_tree:eggcorn", "inv:nc_terrain:dirt_loose"}
)

nc.register_hint("see a tree grow",
	{true,
		"tree growth",
		"nc_tree:tree_bud"
	},
	"eggcorn planting"
)

nc.register_hint("find a stick",
	"nc_tree:stick",
	"dig:nc_tree:leaves"
)

nc.register_hint("cut down a tree",
	"dig:nc_tree:tree",
	"toolcap:choppy:2"
)

nc.register_hint("dig up a tree stump",
	"dig:nc_tree:root",
	"toolcap:choppy:4"
)

nc.register_hint("grind dead plants into peat",
	"compress peat block",
	{true,
		"group:peat_grindable_item",
		"group:peat_grindable_node"
	}
)

nc.register_hint("ferment peat into humus",
	"peat compost",
	"nc_tree:peat"
)
