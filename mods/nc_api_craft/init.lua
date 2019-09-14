-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("register_craft")
include("craft_check")
include("item_place_node")
include("on_punchnode")
include("fx_smoke")
include("register_cook_abm")
