-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("disable")
include("discover")
include("witness")
include("register")
include("state")
include("alerts")
include("reset")
