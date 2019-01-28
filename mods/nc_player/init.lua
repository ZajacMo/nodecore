-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest
    = dofile, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/player.lua")
dofile(path .. "/knowledge.lua")
dofile(path .. "/hotpotato.lua")
