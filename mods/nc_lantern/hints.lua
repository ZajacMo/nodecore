-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("assemble a lantern from a tote handle",
	"assemble lantern",
	{"nc_tote:handle", "nc_optics:glass_opaque"}
)

nodecore.register_hint("charge a lantern",
	"group:" .. modname .. "_charged",
	"assemble lantern"
)

nodecore.register_hint("fully charge a lantern",
	"group:" .. modname .. "_full",
	"assemble lantern"
)
