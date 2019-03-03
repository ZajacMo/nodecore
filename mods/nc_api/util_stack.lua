-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.node_inv(pos)
	return minetest.get_meta(pos):get_inventory()
end

function nodecore.stack_get(pos)
	return nodecore.node_inv(pos):get_stack("solo", 1)
end

function nodecore.stack_set(pos, stack)
	return nodecore.node_inv(pos):set_stack("solo", 1, ItemStack(stack))
end

function nodecore.stack_add(pos, stack)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if def and def.stack_allow then
		local ret = def.stack_allow(pos, node, stack, def)
		if ret == false then return stack end
		if ret and ret ~= true then return ret end
	end
	return nodecore.node_inv(pos):add_item("solo", ItemStack(stack))
end

function nodecore.stack_giveto(pos, player)
	local stack = nodecore.stack_get(pos)
	stack = player:get_inventory():add_item("main", stack)
	nodecore.stack_set(pos, stack)
	return stack:is_empty()
end
