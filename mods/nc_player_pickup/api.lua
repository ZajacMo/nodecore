-- LUALOCALS < ---------------------------------------------------------
local ItemStack, nc
    = ItemStack, nc
-- LUALOCALS > ---------------------------------------------------------

function nc.inv_walk(player, widx, inv, list)
	widx = widx or player:get_wield_index()
	list = list or "main"
	inv = inv or player:get_inventory()
	local size = inv:get_size(list)
	local slots = {}
	for i = widx, size do slots[#slots + 1] = i end
	for i = widx - 1, 1, -1 do slots[#slots + 1] = i end
	local idx = 0
	return function()
		idx = idx + 1
		return slots[idx]
	end
end

function nc.give_item(player, stack, list, inv)
	stack = ItemStack(stack)
	if stack:is_empty() then return stack end

	inv = inv or player:get_inventory()
	for idx in nc.inv_walk(player, nil, inv, list) do
		local s = inv:get_stack(list, idx)
		stack = nc.stack_merge(s, stack)
		inv:set_stack(list, idx, s)
		if stack:is_empty() then return stack end
	end
	return inv:add_item(list, stack)
end
