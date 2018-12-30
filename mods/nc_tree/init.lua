-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore
    = dofile, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_leaf_drops, nodecore.registered_leaf_drops
= nodecore.mkreg()

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/node.lua")

dofile(path .. "/stick.lua")

dofile(path .. "/schematic.lua")
dofile(path .. "/decor.lua")
dofile(path .. "/cultivation.lua")
