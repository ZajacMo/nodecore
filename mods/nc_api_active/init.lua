-- LUALOCALS < ---------------------------------------------------------
local core, include, nc
    = core, include, nc
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

nc.register_limited_abm = function(...)
	nc.log("warning", "deprecated register_limited_abm in "
		.. (core.get_current_modname() or "unknown mod"))
	return core.register_abm(...)
end

include("abmmux")
include("abmdelay")
include("abminvert")
include("abmarea")
include("stasis")
include("dnts")
include("aism")
include("soaking")
include("ambiance")
include("playerstep")
include("dynalight")
include("fluidwander")
