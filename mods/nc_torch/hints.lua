-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_hint("craft a torch from staff and coal lump",
	"assemble torch",
	{"nc_woodwork:staff", "nc_fire:lump_coal"}
)

nc.register_hint("light a torch",
	"group:torch_lit",
	"assemble torch"
)
