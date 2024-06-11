-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include('node')
include('bulknodes')
include('ent_item')
include('ent_falling')
include('hooks')
include('burnup')
include('pulverize')
include('throw_inertia')
include('drop_as')
include('hints')
include('protect')
