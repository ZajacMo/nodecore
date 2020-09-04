-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_ceil, math_pow
    = math.ceil, math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function isfluid(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.groups and def.groups.lux_fluid
end

local indirs = {}
for _, v in pairs(nodecore.dirs()) do
	if v.y == 0 then
		indirs[#indirs + 1] = v
	end
end

function nodecore.lux_soak_rate(pos)
	local above = vector.add(pos, {x = 0, y = 1, z = 0})
	if not isfluid(above) then return false end
	local qty = 1
	for _, v in pairs(indirs) do
		if isfluid(vector.add(pos, v)) then qty = qty + 1 end
	end

	local dist = nodecore.scan_flood(above, 14, function(p, d)
			if p.dir and p.dir.y < 0 then return false end
			local nn = minetest.get_node(p).name
			if nn == modname .. ":flux_source" then return d end
			if nn ~= modname .. ":flux_flowing" then return false end
		end)
	if not dist then return false end

	return qty * 20 / math_pow(2, dist / 2)
end

local function is_lux_cobble(stack)
	return (not stack:is_empty()) and minetest.get_item_group(stack:get_name(), "lux_cobble") > 0
end

function nodecore.lux_react_qty(pos, adjust)
	local minp = vector.subtract(pos, {x = 1, y = 1, z = 1})
	local maxp = vector.add(pos, {x = 1, y = 1, z = 1})
	local qty = #minetest.find_nodes_in_area(minp, maxp, {"group:lux_cobble"})
	if adjust then qty = qty + adjust end
	for _, p in pairs(minetest.find_nodes_with_meta(minp, maxp)) do
		if is_lux_cobble(nodecore.stack_get(p)) then
			qty = qty + 1
		end
	end
	for _, p in pairs(minetest.get_connected_players()) do
		if vector.distance(pos, vector.add(p:get_pos(), {x = 0, y = 1, z = 0})) < 2 then
			local inv = p:get_inventory()
			for i = 1, inv:get_size("main") do
				if is_lux_cobble(inv:get_stack("main", i)) then
					qty = qty + 1
				end
			end
		end
	end
	qty = math_ceil(qty / 2)
	if qty > 8 then qty = 8 end
	if qty < 1 then qty = 1 end
	return qty
end
