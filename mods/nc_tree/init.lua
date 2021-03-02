-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("api")
include("node")
include("leafdecay")
include("compost")

include("stick")

include("schematic")
include("decor")

include("grow_node")
include("grow_active")

include("ambiance")

include("hints")
