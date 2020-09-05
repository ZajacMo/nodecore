-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("melt sand into glass",
	"group:silica",
	"nc_terrain:sand_loose"
)

nodecore.register_hint("quench molten glass into chromatic glass",
	"nc_optics:glass_opaque",
	"group:silica"
)

nodecore.register_hint("mold molten glass into clear glass",
	"nc_optics:glass",
	"group:silica"
)

nodecore.register_hint("mold molten glass into float glass",
	"nc_optics:glass_float",
	{"nc_optics:glass", "group:lava"}
)

nodecore.register_hint("cool molten glass into crude glass",
	"nc_optics:glass_crude",
	"group:silica"
)

nodecore.register_hint("chip chromatic glass into prisms",
	"group:silica_prism",
	{"nc_optics:glass_opaque", "nc_lode:tool_mallet_tempered"}
)

nodecore.register_hint("chop chromatic glass into lenses",
	"group:silica_lens",
	{"nc_optics:glass_opaque", "nc_lode:tool_hatchet_tempered"}
)

nodecore.register_hint("activate a lens",
	"nc_optics:lens_on",
	"group:silica_lens"
)

nodecore.register_hint("produce light from a lens",
	"nc_optics:lens_glow",
	"group:silica_lens"
)

nodecore.register_hint("activate a prism",
	"nc_optics:prism_on",
	"nc_optics:lens_on"
)

nodecore.register_hint("gate a prism",
	"nc_optics:prism_gated",
	"nc_optics:lens_on"
)

nodecore.register_hint("assemble a glass tank",
	"assemble glass tank",
	{"nc_optics:glass", "nc_woodwork:frame"}
)
