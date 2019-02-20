-- LUALOCALS < ---------------------------------------------------------
local include, minetest
    = include, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

include("ore")
include("metallurgy")
include("tools")
