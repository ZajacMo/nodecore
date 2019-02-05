-- LUALOCALS < ---------------------------------------------------------
-- SKIP: nodecore
local dofile, minetest, rawget, rawset, table
    = dofile, minetest, rawget, rawset, table
local table_concat, table_insert
    = table.concat, table.insert
-- LUALOCALS > ---------------------------------------------------------

local nodecore = rawget(_G, "nodecore") or {}
rawset(_G, "nodecore", nodecore)

local include = rawget(_G, "include") or function(...)
	local parts = {...}
	table_insert(parts, 1, minetest.get_modpath(minetest.get_current_modname()))
	if parts[#parts]:sub(-4) ~= ".lua" then
		parts[#parts] = parts[#parts] .. ".lua"
	end
	minetest.log(table_concat(parts, "/"))
	return dofile(table_concat(parts, "/"))
end
rawset(_G, "include", include)

nodecore.version = include("version")

include("issue7020")

include("util_misc")
include("util_scan_flood")
include("util_logtrace")
include("util_node_is")
include("util_toolcaps")

include("register_craft")
include("register_limited_abm")

include("item_on_register")
include("item_drop_in_place")
include("item_falling_repose")
include("item_alternate_loose")
include("item_group_visinv")
include("item_oldnames")
include("item_tool_wears_to")

include("action_node_pummel")
