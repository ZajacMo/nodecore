-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore
    = ItemStack, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.node_inv(pos)
	return minetest.get_meta(pos):get_inventory()
end

function nodecore.stack_get(pos)
	return nodecore.node_inv(pos):get_stack("solo", 1)
end

local function update(pos, ...)
	for _, v in ipairs(nodecore.visinv_update_ents(pos)) do
		v:get_luaentity():itemcheck()
	end
	return ...
end

function nodecore.stack_set(pos, stack)
	return update(pos, nodecore.node_inv(pos):set_stack("solo", 1, ItemStack(stack)))
end

function nodecore.stack_add(pos, stack)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def.stack_allow then
		local ret = def.stack_allow(pos, node, stack)
		if ret == false then return stack end
		if ret and ret ~= true then return ret end
	end
	stack = ItemStack(stack)
	local left = nodecore.node_inv(pos):add_item("solo", stack)
	if left:get_count() ~= stack:get_count() then
		nodecore.stack_sounds(pos, "place")
	end
	return update(pos, left)
end

function nodecore.stack_giveto(pos, player)
	local stack = nodecore.stack_get(pos)
	local qty = stack:get_count()
	if qty < 1 then return true end
	
	stack = player:get_inventory():add_item("main", stack)
	if stack:get_count() == qty then return stack:is_empty() end
	
	nodecore.stack_sounds(pos, "dug")
	nodecore.stack_set(pos, stack)
	return stack:is_empty()
end
