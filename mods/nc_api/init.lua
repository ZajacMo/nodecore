-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore, rawset
    = dofile, minetest, nodecore, rawset
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nodecore = rawget(_G, "nodecore") or {}
rawset(_G, "nodecore", nodecore)

local path = minetest.get_modpath(modname)

dofile(path .. "/util_misc.lua")
dofile(path .. "/util_scan_flood.lua")
dofile(path .. "/util_logtrace.lua")

dofile(path .. "/register_craft.lua")
dofile(path .. "/register_limited_abm.lua")

dofile(path .. "/node_is.lua")
dofile(path .. "/node_on_register.lua")
dofile(path .. "/node_drop_in_place.lua")
dofile(path .. "/node_falling_repose.lua")
dofile(path .. "/node_alternate_loose.lua")
dofile(path .. "/node_group_visinv.lua")

dofile(path .. "/action_node_pummel.lua")

dofile(path .. "/player_knowledge.lua")
