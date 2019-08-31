-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function stackgroup(stack, grp)
	stack = ItemStack(stack)
	if stack:is_empty() then return end
	local name = stack:get_name()
	local def = minetest.registered_items[name]
	return def and def.groups and def.groups[grp] and name
end

local function luxqty(pos)
	local minp = vector.subtract(pos, {x = 1, y = 1, z = 1})
	local maxp = vector.add(pos, {x = 1, y = 1, z = 1})
	local qty = #minetest.find_nodes_in_area(minp, maxp, {"group:lux_emit"})
	for _, p in pairs(minetest.find_nodes_with_meta(minp, maxp)) do
		if stackgroup(nodecore.stack_get(p), "lux_emit") then
			qty = qty + 1
		end
	end
	for _, p in pairs(minetest.get_connected_players()) do
		if vector.distance(pos, vector.add(p:get_pos(), {x = 0, y = 1, z = 0})) < 2 then
			local inv = p:get_inventory()
			for i = 1, inv:get_size("main") do
				if stackgroup(inv:get_stack("main", i), "lux_emit") then
					qty = qty + 1
				end
			end
		end
	end
	qty = math_ceil(qty / 2)
	if qty > 8 then qty = 8 end
	return qty
end

nodecore.register_limited_abm({
	label = "Lux Reaction",
	interval = 1,
	chance = 2,
	limited_max = 100,
	nodenames = {"group:lux_cobble"},
	action = function(pos, node)
		local qty = luxqty(pos)
		local name = node.name:gsub("cobble%d", "cobble" .. qty)
		if name == node.name then return end
		minetest.set_node(pos, {name = name})
	end
})

nodecore.register_limited_abm({
	label = "Lux Stack Reaction",
	interval = 1,
	chance = 2,
	limited_max = 100,
	nodenames = {"group:visinv"},
	action = function(pos)
		local stack = nodecore.stack_get(pos)
		if stack:is_empty() then return end
		local name = stackgroup(stack, "lux_cobble")
		local qty = luxqty(pos)
		name = name:gsub("cobble%d", "cobble" .. qty)
		if name == stack:get_name() then return end
		stack:set_name(name)
		nodecore.stack_set(pos, stack)
	end
})

local function playercheck(player)
	local found
	local stacks = {}
	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if stackgroup(stack, "lux_cobble") then
			stacks[i] = stack
			found = true
		end
	end
	if not found then return end
	local qty = luxqty(vector.add(player:get_pos(), {x = 0, y = 1, z = 0}))
	for k, v in pairs(stacks) do
		local name = v:get_name()
		local nn = name:gsub("cobble%d", "cobble" .. qty)
		if name ~= nn then
			v:set_name(nn)
			inv:set_stack("main", k, v)
		end
	end
end
local function playercheckall()
	minetest.after(1, playercheckall)
	for _, p in pairs(minetest.get_connected_players()) do
		playercheck(p)
	end
end
playercheckall()
