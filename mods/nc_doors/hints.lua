-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("chisel a hinge groove into a wooden plank",
	"drill door plank",
	{"anvil making lode rod", "split tree to planks"}
)

nc.register_hint("insert wooden pin into wooden panel",
	"door pin plank",
	"drill door plank"
)

nc.register_hint("chisel a hinge groove into cobble",
	"drill door cobble",
	{"anvil making lode rod", "nc_terrain:cobble"}
)

nc.register_hint("insert metal rod into a cobble panel",
	"door pin cobble",
	"drill door cobble"
)

nc.register_hint("compress something with a hinged panel",
	"witness:press",
	"group:door"
)

nc.register_hint("catapult an item with a hinged panel",
	"door catapult",
	"group:door"
)

nc.register_hint("propel hinged panel with focused light",
	"door ablation",
	{"group:optic_lens_emit", "group:door"}
)

nc.register_hint("place a node with a hinged panel",
	"witness:door placement",
	"group:door"
)

nc.register_hint("complete an assembly recipe with a hinged panel",
	"witness:door place-craft",
	"group:door"
)

nc.register_hint("complete a pummel with a hinged panel and tool head",
	"witness:door pummel",
	"group:door"
)

nc.register_hint("dig a node with a hinged panel and tool",
	"witness:door dig",
	"group:door"
)

nc.register_hint("push an item into a storage box with a hinged panel",
	"witness:door store",
	"group:door"
)
