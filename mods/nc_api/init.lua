-- LUALOCALS < ---------------------------------------------------------
-- SKIP: nodecore
local dofile, minetest, rawget, rawset
    = dofile, minetest, rawget, rawset
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nodecore = rawget(_G, "nodecore") or {}
rawset(_G, "nodecore", nodecore)

local path = minetest.get_modpath(modname)

dofile(path .. "/util_misc.lua")
dofile(path .. "/util_scan_flood.lua")
dofile(path .. "/util_logtrace.lua")
dofile(path .. "/util_node_is.lua")
dofile(path .. "/util_toolcaps.lua")

dofile(path .. "/register_craft.lua")
dofile(path .. "/register_limited_abm.lua")

dofile(path .. "/item_on_register.lua")
dofile(path .. "/item_drop_in_place.lua")
dofile(path .. "/item_falling_repose.lua")
dofile(path .. "/item_alternate_loose.lua")
dofile(path .. "/item_group_visinv.lua")
dofile(path .. "/item_oldnames.lua")
dofile(path .. "/item_tool_wears_to.lua")

dofile(path .. "/action_node_pummel.lua")

dofile(path .. "/player_knowledge.lua")
