-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_leaf_drops, nodecore.registered_leaf_drops
= nodecore.mkreg()

function nodecore.tree_soil_rate(pos, d, w)
	d = d or 1
	w = w or 1
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

function nodecore.tree_growth_rate(pos)
	local above = {x = pos.x, y = pos.y + 1, z = pos.z}
	if minetest.get_node(above).name ~= "air" then return end
	local ll = nodecore.get_node_light(above)
	if (not ll) or (ll < 8) then return end
	for y = 2, 5 do
		local p = {x = pos.x, y = pos.y + y, z = pos.z}
		local nn = minetest.get_node(p).name
		if nn ~= "air" and nn ~= modname .. ":leaves" then return end
	end
	return nodecore.tree_soil_rate(pos) * math_sqrt((ll - 7) / 8)
end

function nodecore.tree_trunk_growth_rate(pos, node)
	if node and node.name == modname .. ":root" then
		return nodecore.tree_soil_rate(pos)
	end
	local bpos = {x = pos.x, y = pos.y, z = pos.z}
	for _ = 1, #nodecore.tree_params do
		bpos.y = bpos.y - 1
		node = minetest.get_node(bpos)
		if node.name == "ignore" then
			return
		elseif node.name == modname .. ":root" then
			return nodecore.tree_soil_rate(bpos)
		elseif node.name ~= modname .. ":tree" then
			return false
		end
	end
end

function nodecore.calc_leaves(pos)
	local leaflv = nodecore.scan_flood(pos, 2, function(p, d)
			if minetest.get_node(p).name == modname .. ":tree" then
				return 3 - d
			end
		end)
	return {
		name = modname .. ":leaves",
		param2 = leaflv or 0
	}
end
