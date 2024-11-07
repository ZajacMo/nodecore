-- LUALOCALS < ---------------------------------------------------------
local include, nc
    = include, nc
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

include("node_backstop")
include("register_craft")
include("craft_check")
include("item_place_node")
include("on_punchnode")
include("fx_smoke")
include("register_cook_abm")
