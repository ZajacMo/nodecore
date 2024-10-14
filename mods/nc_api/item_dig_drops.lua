-- LUALOCALS < ---------------------------------------------------------
local core, nc, type
    = core, nc, type
-- LUALOCALS > ---------------------------------------------------------

-- Register functions to modify node drops after the standard ones have
-- been calculated by the engine, but before they are returned to the
-- player, or dropped as items, etc.

-- nc.register_on_node_drops(function(pos, node, digger, drops) ... end)

-- modify the drops table in place, OR return a replacement table

nc.register_on_node_drops,
nc.registered_on_node_drops
= nc.mkreg()

local dug
local old_node_dig = core.node_dig
core.node_dig = function(pos, node, digger, ...)
	local function helper(...)
		dug = nil
		return ...
	end
	dug = {pos = pos, node = node, who = digger}
	return helper(old_node_dig(pos, node, digger, ...))
end
local old_get_node_drops = core.get_node_drops
core.get_node_drops = function(...)
	local drops = old_get_node_drops(...)
	if not dug then return drops end
	drops = drops or {}
	for i = 1, #nc.registered_on_node_drops do
		local r = nc.registered_on_node_drops[i](dug.pos, dug.node, dug.who, drops)
		if type(r) == "table" then drops = r end
	end
	return drops
end
