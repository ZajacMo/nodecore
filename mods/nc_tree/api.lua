-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore
    = ipairs, math, minetest, nodecore
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_leaf_drops, nodecore.registered_leaf_drops
= nodecore.mkreg()

function nodecore.leaf_decay(pos, node)
	node = node or minetest.get_node(pos)
	local t = {}
	for _, v in ipairs(nodecore.registered_leaf_drops) do
		t = v(pos, node, t) or t
	end
	local p = nodecore.pickrand(t, function(x) return x.prob end)
	if not p then return end
	minetest.set_node(pos, p)
	if p.item then nodecore.item_eject(pos, p.item) end
	return nodecore.fallcheck(pos)
end

function nodecore.tree_growth_rate(pos)
	local d = 1
	local w = 1
	nodecore.scan_flood(pos, 3, function(p, r)
			if r < 1 then return end
			local nn = minetest.get_node(p).name
			local def = minetest.registered_items[nn] or {}
			if not def.groups then
				return false
			end
			if def.groups.soil then
				d = d + def.groups.soil
				w = w + 0.2
			elseif def.groups.moist then
				w = w + def.groups.moist
				return false
			else
				return false
			end
		end)
	return math_sqrt(d * w)
end
