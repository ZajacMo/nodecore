-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore, rawset
    = dofile, minetest, nodecore, rawset
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore = nodecore or {}
rawset(_G, "nodecore", nodecore)

local path = minetest.get_modpath(modname)

dofile(path .. "/utils.lua")
dofile(path .. "/hints.lua")

dofile(path .. "/node_on_register.lua")
dofile(path .. "/node_drop_in_place.lua")
dofile(path .. "/node_falling_repose.lua")
dofile(path .. "/node_alternate_loose.lua")
dofile(path .. "/node_group_visinv.lua")

dofile(path .. "/action_node_pummel.lua")

dofile(path .. "/player_knowledge.lua")
