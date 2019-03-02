-- LUALOCALS < ---------------------------------------------------------
local include, minetest
    = include, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

include("adze")
include("plank")
include("staff")
include("tools")
include("ladder")
include("shelf")
