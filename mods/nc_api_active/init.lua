-- LUALOCALS < ---------------------------------------------------------
local include, minetest, nodecore
    = include, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

nodecore.register_limited_abm = function(...) return minetest.register_abm(...) end

include("abmmux")
include("abminvert")
include("stasis")
include("dnts")
include("aism")
include("soaking")
include("ambiance")
include("playerstep")
include("dynalight")
