-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("api")
include("node")
include("lumps")
include("abm")
include("firestarting")
include("hints")
