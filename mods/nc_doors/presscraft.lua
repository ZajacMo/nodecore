-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
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
			nodecore.item_eject(
				vector.add(pos, vector.multiply(vel, 0.25)),
				stack:get_name(),
				0,
				1,
				vector.multiply(vel, 4)
			)
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

	nr.label = "press " .. nr.label
	nr.action = "press"
	nr.toolgroups = nil

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
		for _, v in ipairs(nodecore.craft_recipes) do t[#t + 1] = v end
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
