-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, vector
    = ItemStack, ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

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
			local backstop = vector.subtract(vector.multiply(
					data.pointed.under, 2), data.pointed.above)
			return not nodecore.match(backstop, {walkable = true})
		end,
		after = function(pos, data)
			local stack = nodecore.stack_get(pos)
			if (not stack) or stack:is_empty() then return end
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
			local one = ItemStack(stack:to_string())
			one:set_count(1)
			nodecore.item_eject(
				vector.add(pos, vector.multiply(vel, 0.25)),
				one, 0, 1, vector.multiply(vel, 2 + doorlv)
			)
			nodecore.witness(pos, "door catapult")
			stack:take_item(1)
			if stack:is_empty() and nodecore.node_group("is_stack_only", pos) then
				return minetest.remove_node(pos)
			end
			return nodecore.stack_set(pos, stack)
		end
	})
local done = {}

local function backstop(pos, dir, depth)
	if depth <= 0 then return end
	pos = vector.add(pos, dir)
	if nodecore.buildable_to(pos) then return end
	if nodecore.node_group("falling_node", pos) then
		return backstop(pos, dir, depth - 1)
	end
	return true
end

local function pressify(rc)
	if rc.action ~= "pummel" then return end

	local thumpy = rc.toolgroups and rc.toolgroups.thumpy
	if not thumpy then return end

	if done[rc.label] then return end
	done[rc.label] = true

	local nr = {}
	for k, v in pairs(rc) do nr[k] = v end

	nr.action = "press"
	nr.toolgroups = nil
	nr.witness = 16

	local oldcheck = nr.check
	nr.check = function(pos, data)
		if not backstop(pos, vector.subtract(data.pointed.under,
				data.pointed.above), 4) then return end

		local g = nodecore.node_group("door", data.pointed.above) or 0
		if g < thumpy then return end

		if oldcheck then return oldcheck(pos, data) end
		return true
	end

	nodecore.register_craft(nr)
end

minetest.after(0, function()
		local t = {}
		for _, v in ipairs(nodecore.registered_recipes) do t[#t + 1] = v end
		minetest.after(0, function()
				for _, v in ipairs(t) do pressify(v) end
			end)
	end)

local oldreg = nodecore.register_craft
nodecore.register_craft = function(def, ...)
	local function helper(...)
		pressify(def)
		return ...
	end
	return helper(oldreg(def, ...))
end

nodecore.register_craft({
		action = "press",
		label = "press node craft",
		priority = -1,
		nodes = {{match = {groups = {stack_as_node = true}}}},
		check = function(pos, data)
			if not backstop(pos, vector.subtract(data.pointed.under,
					data.pointed.above), 4) then return end
			return true
		end,
		after = function(pos, data)
			return nodecore.craft_check(pos,
				minetest.get_node(pos),
				{
					action = "place",
					pointed = data.pointed,
					witness = 16,
					label = "door place-craft"
				})
		end
	})

local checkedstack = {}
nodecore.register_craft({
		action = "press",
		label = "press place stack",
		priority = 1,
		nodes = {{match = {stacked = true}}},
		check = function(pos, data)
			if not backstop(pos, vector.subtract(data.pointed.under,
					data.pointed.above), 4) then return end

			local stack = nodecore.stack_get(pos)
			if not stack or stack:is_empty() or stack:get_count() ~= 1
			then return end
			local def = stack:get_definition()
			if not (def and def.type == "node")
			or def.groups.stack_as_node then return end

			data[checkedstack] = stack
			return true
		end,
		after = function(pos, data)
			local stack = data[checkedstack]
			if not stack then return end
			minetest.remove_node(pos)
			nodecore.witness(pos, "door placement")
			local pt = {}
			for k, v in pairs(data.pointed) do pt[k] = v end
			pt.craftdata = {
				witness = 16,
				label = "door place-craft"
			}
			stack = minetest.item_place_node(stack, nil, pt)
			nodecore.node_sound(pos, "place")
			if not stack:is_empty() then
				nodecore.item_eject(pos, stack)
			end
		end
	})
