-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("chisel a hinge groove into a wooden plank",
	"drill door plank",
	{"anvil making lode rod", "split tree to planks"}
)

nodecore.register_hint("insert wooden pin into wooden panel",
	"door pin plank",
	"drill door plank"
)

nodecore.register_hint("chisel a hinge groove into cobble",
	"drill door cobble",
	{"anvil making lode rod", "nc_terrain:cobble"}
)

nodecore.register_hint("insert metal rod into a cobble panel",
	"door pin cobble",
	"drill door cobble"
)

nodecore.register_hint("compress something with a hinged panel",
	"witness:press",
	"group:door"
)

nodecore.register_hint("catapult an item with a hinged panel",
	"door catapult",
	"group:door"
)

nodecore.register_hint("propel hinged panel with focused light",
	"door ablation",
	{"nc_optics:lens_on", "group:door"}
)

nodecore.register_hint("place a node with a hinged panel",
	"witness:door placement",
	"group:door"
)

nodecore.register_hint("complete a craft with a hinged panel",
	"witness:door place-craft",
	"group:door"
)

nodecore.register_hint("complete a pummel with a hinged panel and tool head",
	"witness:door pummel",
	"group:door"
)

nodecore.register_hint("dig a node with a hinged panel and tool",
	"witness:door dig",
	"group:door"
)

nodecore.register_hint("put an item in a storage box with a hinged panel",
	"witness:door store",
	"group:door"
)
