-- LUALOCALS < ---------------------------------------------------------
local include, minetest
    = include, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

include('api')
include('node')
include('abm')
include('firestarting')
