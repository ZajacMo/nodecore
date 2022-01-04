-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("assemble a lode tote handle",
	"craft tote handle",
	{"nc_lode:form", "nc_lode:frame_annealed", "group:totable"}
)

nodecore.register_hint("pack up a complete tote",
	"inv:" .. modname .. ":handle_full",
	"craft tote handle"
)
