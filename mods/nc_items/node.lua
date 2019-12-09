-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function pezdispense(pos)
	local above = {x = pos.x, y = pos.y + 1, z = pos.z}
	local node = minetest.get_node(above)
	if node.name ~= modname .. ":stack" then
		return nodecore.visinv_update_ents(pos)
	end
	nodecore.place_stack(pos, nodecore.stack_get(above))
	minetest.remove_node(above)
	nodecore.visinv_update_ents(pos)
	return pezdispense(above)
end

minetest.register_node(modname .. ":stack", {
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		use_texture_alpha = true,
		tiles = {
			"nc_items_shadow.png",
			"[combine:1x1",
		},
		walkable = true,
		selection_box = nodecore.fixedbox(
			{-0.4, -0.5, -0.4, 0.4, 0.3, 0.4}
		),
		collision_box = nodecore.fixedbox(),
		drop = {},
		groups = {
			snappy = 1,
			falling_repose = 1,
			visinv = 1,
			is_stack_only = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		repose_drop = function(posfrom, posto)
			local stack = nodecore.stack_get(posfrom)
			if stack and not stack:is_empty() then
				nodecore.item_eject(posto, stack)
			end
			return minetest.remove_node(posfrom)
		end,
		on_rightclick = function(pos, node, whom, stack, pointed, ...)
			if not nodecore.interact(whom) then return stack end
			local def = nodecore.stack_get(pos):get_definition() or {}
			if def.stack_rightclick then
				local rtn = def.stack_rightclick(pos, node, whom, stack, pointed, ...)
				if rtn then return rtn end
			end
			return nodecore.stack_add(pos, stack)
		end,
		on_construct = function(pos, ...)
			minetest.after(0, function()
					return nodecore.stack_sounds(pos, "place")
				end)
			return nodecore.visinv_on_construct(pos, ...)
		end,
		after_dig_node = pezdispense
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)

	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	if minetest.get_node(below).name == modname .. ":stack" then
		stack = nodecore.stack_add(below, stack)
		if stack:is_empty() then return end
	end

	if stack:get_count() == 1 then
		local def = minetest.registered_nodes[stack:get_name()]
		if def and def.groups and def.groups.stack_as_node then
			minetest.set_node(pos, {name = stack:get_name()})
			if def.after_place_node then
				def.after_place_node(pos, nil, stack)
			end
			return nodecore.fallcheck(pos)
		end
	end

	minetest.set_node(pos, {name = modname .. ":stack", param2 = 1})
	nodecore.stack_set(pos, stack)
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, {
				action = "place",
				crafter = placer,
				pointed = pointed_thing
			})
	end

	return nodecore.fallcheck(pos)
end

minetest.register_lbm({
		label = "Update Stack Node Wallmounted",
		name = modname .. ":wallmounted",
		nodenames = {modname .. ":stack"},
		run_at_every_load = false,
		action = function(pos, node)
			if node.param2 ~= 1 then
				node.param2 = 1
				return minetest.swap_node(pos, node)
			end
		end
	})
