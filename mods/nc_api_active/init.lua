-- LUALOCALS < ---------------------------------------------------------
local include, minetest, nodecore
    = include, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

nodecore.register_limited_abm = function(...)
	nodecore.log("warning", "deprecated register_limited_abm in "
		.. (minetest.get_current_modname() or "unknown mod"))
	return minetest.register_abm(...)
end

include("abmmux")
include("abminvert")
include("stasis")
include("dnts")
include("aism")
include("soaking")
include("ambiance")
include("playerstep")
include("dynalight")
include("fluidwander")
