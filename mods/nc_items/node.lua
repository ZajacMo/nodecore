-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stack", {
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5}
		),
		use_texture_alpha = true,
		tiles = {
			"nc_items_shadow.png",
			"nc_items_blank.png",
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
		end
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)

	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	if minetest.get_node(below).name == modname .. ":stack" then
		stack = nodecore.stack_add(below, stack)
		if stack:is_empty() then return end
	end

	minetest.set_node(pos, {name = modname .. ":stack"})
	nodecore.stack_set(pos, stack)
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, {
				action = "place",
				crafter = placer,
				pointed = pointed_thing
			})
	end

	return minetest.after(0, function() minetest.check_for_falling(pos) end)
end
