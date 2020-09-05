-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("craft a torch from staff and coal lump",
	"assemble torch",
	{"nc_woodwork:staff", "nc_fire:lump_coal"}
)

nodecore.register_hint("light a torch",
	"nc_torch:torch_lit",
	"assemble torch"
)
