-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore, pairs, rawset, type
    = dofile, minetest, nodecore, pairs, rawset, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore = nodecore or {}
rawset(_G, "nodecore", nodecore)
for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

function nodecore.fixedbox(...) return {type = "fixed", fixed = {...}} end

local path = minetest.get_modpath(modname)

dofile(path .. "/node_on_register.lua")

dofile(path .. "/node_drop_in_place.lua")
dofile(path .. "/node_falling_repose.lua")
dofile(path .. "/node_alternate_loose.lua")
dofile(path .. "/node_group_visinv.lua")

dofile(path .. "/action_node_pummel.lua")
