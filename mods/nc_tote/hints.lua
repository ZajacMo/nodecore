-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_hint("assemble a lode tote handle",
	"craft tote handle",
	{"nc_lode:form", "nc_lode:frame_annealed", "group:totable"}
)

nc.register_hint("pack up a complete tote",
	"inv:" .. modname .. ":handle_full",
	"craft tote handle"
)
