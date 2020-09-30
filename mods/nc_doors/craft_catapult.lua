-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, vector
    = ItemStack, minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local function checktarget(data, stack)
	local target = vector.subtract(vector.multiply(
			data.pointed.under, 2), data.pointed.above)
	local node = minetest.get_node(target)
	local def = minetest.registered_items[node.name] or {walkable = true}
	if def.groups and def.groups.visinv and (def.groups.is_stack_only
		or def.storebox_access and def.storebox_access({
				type = "node",
				above = target,
				under = vector.subtract(vector.multiply(
						target, 2), data.pointed.under)
			})) then
		local one = ItemStack(stack:to_string())
		one:set_count(1)
		local tstack = nodecore.stack_get(target)
		if not tstack:item_fits(one) then return end
		data.intostorebox = target
		return true
	end
	return not def.walkable
end

local function doitemeject(pos, data)
	local stack = nodecore.stack_get(pos)
	if (not stack) or stack:is_empty() then return end
	local one = ItemStack(stack:to_string())
	one:set_count(1)
	if data.intostorebox then
		one = nodecore.stack_add(data.intostorebox, one)
		if not one:is_empty() then return end
	else
		local ctr = {
			x = data.axis.x ~= 0 and data.axis.x or pos.x,
			y = data.axis.y ~= 0 and data.axis.y or pos.y,
			z = data.axis.z ~= 0 and data.axis.z or pos.z
		}
		local vel = vector.add(
			vector.subtract(pos, ctr),
			vector.subtract(data.pointed.under, data.pointed.above)
		)
		local doorlv = minetest.get_item_group(minetest.get_node(
				data.pointed.above).name, "door") or 0
		nodecore.item_eject(
			vector.add(pos, vector.multiply(vel, 0.25)),
			one, 0, 1, vector.multiply(vel, 2 + doorlv)
		)
	end
	nodecore.witness(pos, "door catapult")
	stack:take_item(1)
	if stack:is_empty() and nodecore.node_group("is_stack_only", pos) then
		return minetest.remove_node(pos)
	end
	return nodecore.stack_set(pos, stack)
end

nodecore.register_craft({
		action = "press",
		label = "eject item",
		priority = -1,
		nodes = {
			{match = {stacked = true, count = false}}
		},
		check = function(pos, data)
			local stack = nodecore.stack_get(pos)
			if (not stack) or stack:is_empty() then return end
			return checktarget(data, stack)
		end,
		after = doitemeject
	})

nodecore.register_craft({
		action = "press",
		label = "eject from storebox",
		priority = -1,
		nodes = {
			{match = {groups = {storebox = true}}}
		},
		check = function(pos, data)
			local stack = nodecore.stack_get(pos)
			if (not stack) or stack:is_empty() then return end

			if not checktarget(data, stack) then return end

			local pt = data.pointed
			local node = minetest.get_node(pt.under)
			local def = minetest.registered_items[node.name] or {}
			if not def.storebox_access then return end

			local access = {
				type = "node",
				above = vector.add(vector.multiply(
						vector.subtract(pt.above, pt.under),
						-1), pt.under),
				under = pt.under
			}
			return def.storebox_access(access)
		end,
		after = doitemeject
	})
