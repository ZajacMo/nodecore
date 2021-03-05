-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include('api')
include('node')
include('dungeon')
include('biome')
include('strata')
include('ore')
include('abm')
include('ambiance')
include('hints')
