-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local function backstop(pos, dir, depth)
	if depth <= 0 then return end
	pos = vector.add(pos, dir)
	if nodecore.buildable_to(pos) then return end
	if nodecore.node_group("falling_node", pos) then
		return backstop(pos, dir, depth - 1)
	end
	return true
end

local done = {}
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
		nodes = {{match = {groups = {stack_as_node = true, stacked = false}}}},
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

local presstoolcaps = {}
minetest.after(0, function()
		for name, def in pairs(minetest.registered_items) do
			if def.tool_capabilities then
				presstoolcaps[name] = "dig"
			elseif def.tool_head_capabilities then
				presstoolcaps[name] = def.tool_head_capabilities.groupcaps
			end
		end
	end)

nodecore.register_craft({
		action = "press",
		label = "press tool use",
		priority = -10,
		nodes = {{match = {stacked = true}}},
		check = function(_, data)
			local stack = nodecore.stack_get(data.pointed.under)
			local caps = presstoolcaps[stack:get_name()]
			if not caps then return end

			local target = vector.subtract(vector.multiply(
					data.pointed.under, 2), data.pointed.above)
			data.presstarget = target
			local tnode = minetest.get_node(target)
			local tdef = minetest.registered_items[tnode.name]
			if caps == "dig" then
				if not (tdef and tdef.groups and nodecore.tool_digs(
						stack, tdef.groups)) then return end
				data.presscommit = "dig"
				return true
			end

			local pumdata = {
				action = "pummel",
				pos = target,
				pointed = {
					type = "node",
					above = data.pointed.under,
					under = target
				},
				node = tnode,
				nodedef = tdef,
				duration = 3600,
				toolgroupcaps = caps
			}
			local recipe = nodecore.craft_search(target, tnode, pumdata)
			data.presscommit = recipe
			return recipe
		end,
		after = function(_, data)
			if data.presscommit == "dig" then
				return minetest.dig_node(data.presstarget)
			else
				return data.presscommit()
			end
		end
	})
