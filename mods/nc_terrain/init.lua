-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore
    = dofile, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

nodecore.hard_stone_strata = 7

dofile(path .. "/node.lua")
dofile(path .. "/biome.lua")
dofile(path .. "/ore.lua")
dofile(path .. "/grasslife.lua")
