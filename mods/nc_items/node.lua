-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, math, nc
    = ItemStack, core, math, nc
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.stack_node_sounds_except = {}

local bulkskey = "registered_" .. modname .. "_bulk_nodes"
local bulks = nc[bulkskey] or {}
nc[bulkskey] = bulks

function nc.stack_bulk_check(pos, node, stack)
	stack = stack or nc.stack_get(pos)
	local bulk = bulks[stack:get_name()]
	if (not bulk) or stack:get_count() ~= stack:get_stack_max() then
		if node.name == modname .. ":stack" then return end
		return {name = modname .. ":stack"}
	end
	if node and node.name == bulk then return end
	local rot = (pos.x * 3 + pos.y * 5 + pos.z * 7) % 4
	return {name = bulk, param2 = rot}
end

core.register_node(modname .. ":stack", {
		description = "",
		drawtype = "airlike",
		walkable = true,
		selection_box = nc.fixedbox(
			{-0.4, -0.5, -0.4, 0.4, 0.3, 0.4}
		),
		collision_box = nc.fixedbox(),
		drop = {},
		groups = {
			snappy = 1,
			falling_repose = 1,
			visinv = 1,
			is_stack_only = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		repose_drop = function(posfrom, _, posto)
			local stack = nc.stack_get(posfrom)
			if stack and not stack:is_empty() then
				nc.item_eject(posto, stack)
			end
			return core.remove_node(posfrom)
		end,
		can_item_fall_in = function(pos, _, stack)
			if not (nc.stack_get(pos):is_empty() or stack:is_empty()) then return end
			return true
		end,
		on_stack_change = function(pos, node, stack)
			local nn = nc.stack_bulk_check(pos, node, stack)
			if nn then return core.swap_node(pos, nn) end
		end,
		on_rightclick = function(pos, _, whom, stack, pointed)
			if not nc.interact(whom) then return stack end

			if whom and whom.get_wielded_item
			and nc.craft_check(pos, core.get_node(pos), {
					action = "stackapply",
					crafter = whom,
					pointed = pointed
				}) then
				return whom:get_wielded_item()
			end

			return nc.stack_add(pos, stack)
		end,
		on_construct = function(pos, ...)
			local key = core.hash_node_position(pos)
			core.after(0, function()
					local except = nc.stack_node_sounds_except[key]
					nc.stack_node_sounds_except[key] = nil
					return except == true
					or nc.stack_sounds(pos, "place", nil, except)
				end)
			return nc.visinv_on_construct(pos, ...)
		end,
		on_settle_item = function(pos, _, stack)
			return nc.stack_add(pos, stack)
		end,
		on_falling_check = function(pos)
			local stack = nc.stack_get(pos)
			stack = nc.stack_settle({x = pos.x, y = pos.y - 1, z = pos.z}, stack)
			if stack:is_empty() then
				core.remove_node(pos)
			else
				nc.stack_set(pos, stack)
			end
			return false
		end,
		mapcolor = {a = 0},
	})

function nc.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)

	stack = nc.stack_settle({x = pos.x, y = pos.y - 1, z = pos.z}, stack)
	if stack:is_empty() then return end

	if stack:get_count() == 1 then
		local def = core.registered_nodes[stack:get_name()]
		if def and def.groups and def.groups.stack_as_node then
			local node = {name = stack:get_name()}
			if def.paramtype2 == "facedir" then
				node.param2 = math_random(0, 3)
			end
			nc.set_loud(pos, node)
			if def.after_place_node then
				def.after_place_node(pos, nil, stack)
			end
			return nc.fallcheck(pos)
		end
	end

	local nn = nc.stack_bulk_check(pos, core.get_node(pos), stack)
	if nn then nc.set_node(pos, nn) end
	nc.stack_set(pos, stack, placer)
	if placer and pointed_thing then
		nc.craft_check(pos, {name = stack:get_name()}, {
				action = "place",
				crafter = placer,
				pointed = pointed_thing
			})
	end
	local data = nc.craft_cooking_data()
	nc.craft_check(pos, core.get_node(pos), data)

	return nc.fallcheck(pos)
end
