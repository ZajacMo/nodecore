-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_nodeupdate,
nodecore.registered_on_nodeupdates
= nodecore.mkreg()

local hash = minetest.hash_node_position

local mask = {}

local function notify_node_update(pos, node, ...)
	local phash = hash(pos)
	if mask[phash] then return ... end
	mask[phash] = true
	node = node or minetest.get_node(pos)
	local nups = nodecore.registered_on_nodeupdates
	for i = 1, #nups do
		(nups[i])(pos, node)
	end
	mask[phash] = nil
	return ...
end
nodecore.notify_node_update = notify_node_update

for fn, param in pairs({
		set_node = true,
		add_node = true,
		remove_node = false,
		swap_node = true,
		dig_node = false,
		place_node = true,
		add_node_level = false
	}) do
	local func = minetest[fn]
	minetest[fn] = function(pos, pn, ...)
		return notify_node_update(pos, param and pn, func(pos, pn, ...))
	end
end

if minetest.register_on_liquid_transformed then
	minetest.register_on_liquid_transformed(function(list)
			for i = 1, #list do
				notify_node_update(list[i])
			end
		end)
end
