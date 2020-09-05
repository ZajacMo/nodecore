-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("mix gravel into ash to make aggregate",
	"mix concrete",
	{"nc_terrain:gravel_loose", "nc_fire:ash"}
)

nodecore.register_hint("make wet aggregate",
	{true, "nc_concrete:wet_source", "nc_concrete:wet_flowing"},
	"mix concrete"
)
