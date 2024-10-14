-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, vector
    = core, ipairs, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local backstop = nc.node_backstop

local done = {}
local function pressify(rc)
	if rc.action ~= "pummel" then return end

	local thumpy = rc.toolgroups and rc.toolgroups.thumpy
	if not thumpy then return end

	if done[rc] then return end
	done[rc] = true

	local nr = {}
	for k, v in pairs(rc) do nr[k] = v end

	nr.action = "press"
	nr.toolgroups = nil
	nr.witness = 16

	local oldcheck = nr.check
	nr.check = function(pos, data)
		if not backstop(pos, vector.subtract(data.pointed.under,
				data.pointed.above), 4) then return end

		local g = nc.node_group("door", data.pointed.above) or 0
		if g < thumpy then return end

		if oldcheck then return oldcheck(pos, data) end
		return true
	end

	nc.register_craft(nr)
end

core.after(0, function()
		local t = {}
		for _, v in ipairs(nc.registered_recipes) do t[#t + 1] = v end
		core.after(0, function()
				for _, v in ipairs(t) do pressify(v) end
			end)
	end)

local oldreg = nc.register_craft
nc.register_craft = function(def, ...)
	local function helper(...)
		pressify(def)
		return ...
	end
	return helper(oldreg(def, ...))
end

nc.register_craft({
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
			return nc.craft_check(pos,
				core.get_node(pos),
				{
					action = "place",
					pointed = data.pointed,
					witness = 16,
					discover = "door place-craft"
				})
		end
	})

local checkedstack = {}
local recipefound = {}
nc.register_craft({
		action = "press",
		label = "press place stack",
		priority = 1,
		nodes = {{match = {stacked = true}}},
		check = function(pos, data)
			if not backstop(pos, vector.subtract(data.pointed.under,
					data.pointed.above), 4) then return end

			local stack = nc.stack_get(pos)
			if not stack or stack:is_empty() or stack:get_count() ~= 1
			then return end

			local def = stack:get_definition()
			if def and def.type == "node"
			and not def.place_as_item then
				data[checkedstack] = stack
				return true
			end

			data[recipefound] = nc.craft_search(pos,
				core.get_node(pos),
				{
					action = "place",
					pointed = data.pointed,
					witness = 16,
					discover = "door place-craft"
				})
			return data[recipefound]
		end,
		after = function(pos, data)
			if data[recipefound] then
				return data[recipefound]()
			end
			local stack = data[checkedstack]
			if not stack then return end
			core.remove_node(pos)
			local pt = {}
			for k, v in pairs(data.pointed) do pt[k] = v end
			pt.craftdata = {
				witness = 16,
				discover = "door place-craft"
			}
			local def = stack:get_definition()
			if def and def.on_place_node then
				stack = def.on_place_node(stack, nil, pt) or stack
			else
				local param2 = 0
				if def.paramtype2 == "facedir" then
					local dir = vector.subtract(pt.under, pt.above)
					local key = def.on_place == core.rotate_node
					and "b" or "k"
					for k, v in pairs(nc.facedirs) do
						if vector.equals(v[key], dir) then
							param2 = k
							break
						end
					end
				elseif def.paramtype2 == "4dir" then
					local dir = vector.subtract(pt.under, pt.above)
					param2 = core.dir_to_fourdir(dir)
				end
				stack = nc.protection_bypass(core.item_place_node,
					stack, nil, pt, param2)
			end
			nc.node_sound(pos, "place")
			nc.witness({pos, data.pointed.above}, "door placement")
			if not stack:is_empty() then
				nc.item_eject(pos, stack)
			end
		end
	})
