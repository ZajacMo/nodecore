-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_leaf_drops, nc.registered_leaf_drops
= nc.mkreg()

function nc.tree_soil_rate(pos, d, w)
	d = d or 1
	w = w or 1
	nc.scan_flood(pos, 3, function(p, r)
			if r < 1 then return end
			local nn = core.get_node(p).name
			local def = core.registered_items[nn] or {}
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

function nc.tree_growth_rate(pos)
	local above = {x = pos.x, y = pos.y + 1, z = pos.z}
	if not nc.air_equivalent(above) then return end
	local ll = nc.get_node_light(above)
	if (not ll) or (ll < 8) then return end
	for y = 2, 5 do
		local p = {x = pos.x, y = pos.y + y, z = pos.z}
		if not (nc.air_equivalent(p) or core.get_node(p).name
			== modname .. ":leaves") then return end
	end
	return nc.tree_soil_rate(pos) * math_sqrt((ll - 7) / 8)
end

function nc.tree_trunk_growth_rate(pos, node)
	if node and node.name == modname .. ":root" then
		return nc.tree_soil_rate(pos)
	end
	local bpos = {x = pos.x, y = pos.y, z = pos.z}
	for _ = 1, #nc.tree_params do
		bpos.y = bpos.y - 1
		node = core.get_node(bpos)
		if node.name == "ignore" then
			return
		elseif node.name == modname .. ":root" then
			return nc.tree_soil_rate(bpos)
		elseif node.name ~= modname .. ":tree" then
			return false
		end
	end
end

function nc.calc_leaves(pos)
	local leaflv = nc.scan_flood(pos, 2, function(p, d)
			if core.get_node(p).name == modname .. ":tree" then
				return 3 - d
			end
		end)
	return {
		name = modname .. ":leaves",
		param2 = leaflv or 0
	}
end
