-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("stasis")
include("limited_abm")
include("aism")
include("soaking")
include("ambiance")
