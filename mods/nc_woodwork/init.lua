-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest
    = dofile, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/adze.lua")
dofile(path .. "/plank.lua")
dofile(path .. "/staff.lua")
dofile(path .. "/toolhead.lua")
