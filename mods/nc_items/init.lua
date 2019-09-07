-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include('node')
include('ent_item')
include('ent_falling')
include('hooks')
include('burnup')
