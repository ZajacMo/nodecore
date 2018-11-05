-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest
    = dofile, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/api.lua")
dofile(path .. "/node.lua")
