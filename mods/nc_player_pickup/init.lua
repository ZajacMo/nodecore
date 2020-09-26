-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("api")
include("intercept")
include("dropall")
include("hints")
