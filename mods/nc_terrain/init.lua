local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/node.lua")

minetest.clear_registered_biomes()
minetest.clear_registered_ores()
minetest.clear_registered_decorations()

dofile(path .. "/biome.lua")
dofile(path .. "/decor.lua")
