-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore
    = ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_leaf_drops, nodecore.registered_leaf_drops
= nodecore.mkreg()

function nodecore.leaf_decay(pos, node) 
	node = node or minetest.get_node(pos)
	local t = {}
	for i, v in ipairs(nodecore.registered_leaf_drops) do
		t = v(pos, node, t) or t
	end
	local p = nodecore.pickrand(t, function(x) return x.prob end)
	if not p then return end
	minetest.set_node(pos, p)
	if p.item then nodecore.item_eject(pos, p.item) end
	return minetest.check_for_falling(pos)
end
