-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

-- Register functions to modify node drops after the standard ones have
-- been calculated by the engine, but before they are returned to the
-- player, or dropped as items, etc.

-- nodecore.register_on_node_drops(function(pos, node, digger, drops) ... end)

-- modify the drops table in place, OR return a replacement table

nodecore.register_on_node_drops,
nodecore.registered_on_node_drops
= nodecore.mkreg()

local dug
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, digger, ...)
	local function helper(...)
		dug = nil
		return ...
	end
	dug = {pos = pos, node = node, who = digger}
	return helper(old_node_dig(pos, node, digger, ...))
end
local old_get_node_drops = minetest.get_node_drops
minetest.get_node_drops = function(...)
	local drops = old_get_node_drops(...)
	if not dug then return drops end
	drops = drops or {}
	for i = 1, #nodecore.registered_on_node_drops do
		local r = nodecore.registered_on_node_drops[i](dug.pos, dug.node, dug.who, drops)
		if type(r) == "table" then drops = r end
	end
	return drops
end
