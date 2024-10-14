-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_hint("assemble a lantern from a tote handle",
	"assemble lantern",
	{"nc_tote:handle", "nc_optics:glass_opaque"}
)

nc.register_hint("charge a lantern",
	"group:" .. modname .. "_charged",
	"assemble lantern"
)

nc.register_hint("fully charge a lantern",
	"group:" .. modname .. "_full",
	"assemble lantern"
)
