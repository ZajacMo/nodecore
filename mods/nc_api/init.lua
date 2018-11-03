-- LUALOCALS < ---------------------------------------------------------
local dofile, ipairs, minetest, nodecore, pairs, rawset, type
    = dofile, ipairs, minetest, nodecore, pairs, rawset, type
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

nodecore.registered_on_register_node = {}
local oldreg = minetest.register_node
function minetest.register_node(name, def, ...)
	for _, v in ipairs(nodecore.registered_on_register_node) do
		local x = v(name, def, ...)
		if x then return x end
	end
	return oldreg(name, def, ...)
end
function nodecore.register_on_register_node(func)
	local t = nodecore.registered_on_register_node
	t[#t + 1] = func
end

local path = minetest.get_modpath(modname)

dofile(path .. "/node_drop_in_place.lua")
dofile(path .. "/node_falling_repose.lua")
dofile(path .. "/node_alternate_loose.lua")

dofile(path .. "/action_node_pummel.lua")
