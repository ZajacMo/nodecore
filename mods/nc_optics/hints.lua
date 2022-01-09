-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("melt sand into molten glass",
	"group:silica_molten",
	"nc_terrain:sand_loose"
)

nodecore.register_hint("quench molten glass into chromatic glass",
	"quench opaque glass",
	"group:silica_molten"
)

nodecore.register_hint("mold molten glass into clear glass",
	"cool clear glass",
	"group:silica_molten"
)

nodecore.register_hint("mold molten glass into float glass",
	"cool float glass",
	{"cool clear glass", "group:lava"}
)

nodecore.register_hint("cool molten glass into crude glass",
	"nc_optics:glass_crude",
	"group:silica_molten"
)

nodecore.register_hint("chip chromatic glass into prisms",
	"hammer prism from glass",
	{"nc_optics:glass_opaque", "nc_lode:tool_mallet_tempered"}
)

nodecore.register_hint("chop chromatic glass into lenses",
	"cleave lenses from glass",
	{"nc_optics:glass_opaque", "nc_lode:tool_hatchet_tempered"}
)

nodecore.register_hint("activate a lens",
	{true, "group:optic_lens_emit"},
	"group:silica_lens"
)

nodecore.register_hint("produce light from a lens",
	{true, "nc_optics:lens_glow", "nc_optics:lens_glow_glued"},
	"group:silica_lens"
)

nodecore.register_hint("activate a prism",
	{true, "nc_optics:prism_on", "nc_optics:prism_on_glued"},
	"group:optic_lens_emit"
)

nodecore.register_hint("gate a prism",
	{true, "nc_optics:prism_gated", "nc_optics:prism_gated_glued"},
	"group:optic_lens_emit"
)

nodecore.register_hint("stick a lens/prism in place",
	"glue optic",
	{"nc_tree:eggcorn", "group:optic_gluable"}
)

nodecore.register_hint("assemble a clear glass case",
	"assemble clear glass case",
	{"nc_optics:glass", "nc_woodwork:form"}
)
nodecore.register_hint("assemble a float glass case",
	"assemble float glass case",
	{"nc_optics:glass_float", "nc_woodwork:form"}
)
