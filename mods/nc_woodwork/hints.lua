-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("assemble a staff from sticks",
	"assemble staff",
	"nc_tree:stick"
)

nodecore.register_hint("assemble an adze out of sticks",
	"assemble wood adze",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

nodecore.register_hint("assemble a wooden ladder from sticks",
	"assemble wood ladder",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

nodecore.register_hint("assemble a wooden frame from staves",
	"assemble wood frame",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

nodecore.register_hint("convert a wooden frame to a form",
	"wooden frame to form",
	{true, "nc_woodwork:frame"}
)

nodecore.register_hint("convert a wooden form to a frame",
	"wooden form to frame",
	{true, "nc_woodwork:form"}
)

nodecore.register_hint("split a tree trunk into planks",
	"split tree to planks",
	{true, "nc_woodwork:adze", "nc_woodwork:tool_hatchet"}
)

nodecore.register_hint("carve wooden tool heads from planks",
	"carve nc_woodwork:plank",
	"split tree to planks"
)

nodecore.register_hint("assemble a wooden tool",
	{true,
		"assemble wood mallet",
		"assemble wood spade",
		"assemble wood hatchet",
		"assemble wood pick",
	},
	"carve nc_woodwork:plank"
)

nodecore.register_hint("carve a wooden plank completely",
	"carve nc_woodwork:toolhead_pick",
	"carve nc_woodwork:plank"
)

nodecore.register_hint("bash a plank into sticks",
	"bash planks to sticks",
	{"nc_woodwork:plank", "toolcap:thumpy:3"}
)

nodecore.register_hint("brace a wooden form with a stick",
	"assemble braced wood form",
	{"nc_tree:stick", "nc_woodwork:form"}
)

nodecore.register_hint("assemble a wooden shelf from a form and plank",
	"assemble wood shelf",
	{"nc_woodwork:plank", "nc_woodwork:form"}
)

nodecore.register_hint("assemble a rake from adzes and a staff",
	"assemble rake",
	"assemble wood adze"
).hide = true
