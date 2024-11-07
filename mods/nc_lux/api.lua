-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, vector
    = core, math, nc, pairs, vector
local math_ceil, math_pow
    = math.ceil, math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function isfluid(pos)
	local def = core.registered_nodes[core.get_node(pos).name]
	return def and def.groups and def.groups.lux_fluid
end

local indirs = {}
for _, v in pairs(nc.dirs()) do
	if v.y == 0 then
		indirs[#indirs + 1] = v
	end
end

local checkflow
do
	local src = modname .. ":flux_source"
	local flow = modname .. ":flux_flowing"
	local hashpos = core.hash_node_position
	local cache = {}
	checkflow = function(pos, nextpos, ...)
		local nn = core.get_node(pos).name
		if nn == src then return 1 end
		if nn ~= flow then return end
		if nextpos then return checkflow(nextpos, ...) end
		local d = cache[hashpos(pos)]
		return d and d + 1
	end
	core.register_abm({
			label = "trace flux sources",
			chance = 2,
			interval = 1,
			nodenames = {flow},
			action = function(pos)
				local d = checkflow({x = pos.x, y = pos.y + 1, z = pos.z})
				if d then cache[hashpos(pos)] = d return end
				d = checkflow(
					{x = pos.x - 1, y = pos.y, z = pos.z},
					{x = pos.x - 1, y = pos.y + 1, z = pos.z}
				)
				local e = checkflow(
					{x = pos.x + 1, y = pos.y, z = pos.z},
					{x = pos.x + 1, y = pos.y + 1, z = pos.z}
				)
				d = (d and e and d < e and d or e) or d or e
				e = checkflow(
					{x = pos.x, y = pos.y, z = pos.z - 1},
					{x = pos.x, y = pos.y + 1, z = pos.z - 1}
				)
				d = (d and e and d < e and d or e) or d or e
				e = checkflow(
					{x = pos.x, y = pos.y, z = pos.z + 1},
					{x = pos.x, y = pos.y + 1, z = pos.z + 1}
				)
				d = (d and e and d < e and d or e) or d or e
				cache[hashpos(pos)] = d
			end
		})
end

function nc.lux_soak_rate(pos)
	local above = vector.add(pos, {x = 0, y = 1, z = 0})
	if not isfluid(above) then return false end
	local qty = 1
	for _, v in pairs(indirs) do
		if isfluid(vector.add(pos, v)) then qty = qty + 1 end
	end

	local nn = core.get_node(above).name
	if nn == modname .. ":flux_source" then return qty * 20 end
	if nn ~= modname .. ":flux_flowing" then return false end
	local dist = checkflow(above)
	if not dist then return end -- cache may not be filled
	if dist > 14 then return false end

	return qty * 20 / math_pow(2, dist / 2)
end

local function is_lux_cobble(stack)
	return (not stack:is_empty()) and core.get_item_group(stack:get_name(), "lux_cobble") > 0
end

function nc.lux_react_qty(pos, adjust)
	local minp = vector.subtract(pos, {x = 1, y = 1, z = 1})
	local maxp = vector.add(pos, {x = 1, y = 1, z = 1})
	local qty = #core.find_nodes_in_area(minp, maxp, {"group:lux_cobble"})
	if adjust then qty = qty + adjust end
	for _, p in pairs(core.find_nodes_with_meta(minp, maxp)) do
		if is_lux_cobble(nc.stack_get(p)) then
			qty = qty + 1
		end
	end
	for _, p in pairs(core.get_connected_players()) do
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
