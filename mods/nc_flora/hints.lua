-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("find a rush",
	"nc_flora:rush"
)

nodecore.register_hint("dry out a rush",
	"nc_flora:rush_dry",
	"nc_flora:rush"
)

nodecore.register_hint("grow a rush on moist soil",
	"rush spread",
	"nc_flora:rush"
)

nodecore.register_hint("find a sedge",
	"group:flora_sedges"
)

nodecore.register_hint("pick a sedge",
	"inv:nc_flora:sedge_1",
	"group:flora_sedges"
)

nodecore.register_hint("grow a sedge on moist grass",
	"sedge growth",
	"group:flora_sedges"
)

nodecore.register_hint("find a flower",
	"group:flower_living"
)

nodecore.register_hint("wilt a flower",
	"group:flower_wilted",
	"group:flower_living"
)

nodecore.register_hint("grow a flower on moist soil",
	"flower spread",
	"group:flower_living"
)

nodecore.register_hint("breed a new flower variety",
	"group:flower_mutant",
	{"group:flower_living", "flower spread"}
)
