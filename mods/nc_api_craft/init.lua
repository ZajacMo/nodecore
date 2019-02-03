-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest
    = dofile, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/register_craft.lua")
dofile(path .. "/craft_check.lua")
dofile(path .. "/item_place_node.lua")
