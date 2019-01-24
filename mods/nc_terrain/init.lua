-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest
    = dofile, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/node.lua")
dofile(path .. "/biome.lua")
dofile(path .. "/ore.lua")
dofile(path .. "/grasslife.lua")
