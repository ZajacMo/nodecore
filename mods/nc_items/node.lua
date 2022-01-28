-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.stack_node_sounds_except = {}

local boxable_nodes = {}

local function register_stack(name, tiles)
	local stack_name = modname .. ":fullstack_" .. name:gsub(":", "__")
	boxable_nodes[name] = stack_name
	if not tiles then
		minetest.register_node(stack_name, {})
		return
	end
	minetest.register_node(":" .. stack_name, {
			description = "",
			drawtype = "mesh",
			mesh = modname .. "_stack.obj",
			tiles = tiles,
			walkable = true,
			selection_box = nodecore.fixedbox(
				{-0.4, -0.5, -0.4, 0.4, 0.3, 0.4}
			),
			collision_box = nodecore.fixedbox(),
			drop = {},
			groups = {
				snappy = 1,
				falling_repose = 1,
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
			on_stack_unfill = function(pos, stack)
				minetest.swap_node(pos, {name = modname .. ":stack"})
			end,
			on_rightclick = function(pos, _, whom, stack, pointed)
				if not nodecore.interact(whom) then return stack end

				if whom and whom.get_wielded_item
				and nodecore.craft_check(pos, minetest.get_node(pos), {
						action = "stackapply",
						crafter = whom,
						pointed = pointed
					}) then
					return whom:get_wielded_item()
				end

				return nodecore.stack_add(pos, stack)
			end,
			on_construct = function(pos, ...)
				local key = minetest.hash_node_position(pos)
				minetest.after(0, function()
						local except = nodecore.stack_node_sounds_except[key]
						nodecore.stack_node_sounds_except[key] = nil
						return except == true
						or nodecore.stack_sounds(pos, "place", nil, except)
					end)
				return nodecore.visinv_on_construct(pos, ...)
			end,
			on_settle_item = function(pos, _, stack)
				return nodecore.stack_add(pos, stack)
			end,
			on_falling_check = function(pos)
				local stack = nodecore.stack_get(pos)
				stack = nodecore.stack_settle({x = pos.x, y = pos.y - 1, z = pos.z}, stack)
				if stack:is_empty() then
					minetest.remove_node(pos)
				else
					nodecore.stack_set(pos, stack)
				end
				return false
			end
		})
end

-- Registration happens in 2 passes:
-- * The first pass registers the node.
-- * The second pass sets the textures.
-- This is needed to avoid mod dependencies to every boxable node
local to_box = {
	"nc_terrain:cobble",
	"nc_tree:log",
}
for _, name in ipairs(to_box) do
	register_stack(name, nil)
end
minetest.after(0, function()
	for _, name in ipairs(to_box) do
		local def = minetest.registered_nodes[name]
		register_stack(name, def.tiles)
	end
end)

minetest.register_node(modname .. ":stack", {
		description = "",
		drawtype = "airlike",
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
		on_stack_fill = function(pos, stack)
			local box = boxable_nodes[stack:get_name()]
			if box then
				minetest.swap_node(pos, {name = box})
			end
		end,
		on_rightclick = function(pos, _, whom, stack, pointed)
			if not nodecore.interact(whom) then return stack end

			if whom and whom.get_wielded_item
			and nodecore.craft_check(pos, minetest.get_node(pos), {
					action = "stackapply",
					crafter = whom,
					pointed = pointed
				}) then
				return whom:get_wielded_item()
			end

			return nodecore.stack_add(pos, stack)
		end,
		on_construct = function(pos, ...)
			local key = minetest.hash_node_position(pos)
			minetest.after(0, function()
					local except = nodecore.stack_node_sounds_except[key]
					nodecore.stack_node_sounds_except[key] = nil
					return except == true
					or nodecore.stack_sounds(pos, "place", nil, except)
				end)
			return nodecore.visinv_on_construct(pos, ...)
		end,
		on_settle_item = function(pos, _, stack)
			return nodecore.stack_add(pos, stack)
		end,
		on_falling_check = function(pos)
			local stack = nodecore.stack_get(pos)
			stack = nodecore.stack_settle({x = pos.x, y = pos.y - 1, z = pos.z}, stack)
			if stack:is_empty() then
				minetest.remove_node(pos)
			else
				nodecore.stack_set(pos, stack)
			end
			return false
		end
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)

	stack = nodecore.stack_settle({x = pos.x, y = pos.y - 1, z = pos.z}, stack)
	if stack:is_empty() then return end

	if stack:get_count() == 1 then
		local def = minetest.registered_nodes[stack:get_name()]
		if def and def.groups and def.groups.stack_as_node then
			nodecore.set_loud(pos, {name = stack:get_name()})
			if def.after_place_node then
				def.after_place_node(pos, nil, stack)
			end
			return nodecore.fallcheck(pos)
		end
	end

	local box_name = boxable_nodes[stack:get_name()]
	if box_name and stack:get_count() >= stack:get_stack_max() then
		minetest.set_node(pos, {name = box_name})
	else
		minetest.set_node(pos, {name = modname .. ":stack"})
	end
	nodecore.stack_set(pos, stack, placer)
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, {
				action = "place",
				crafter = placer,
				pointed = pointed_thing
			})
	end
	local data = nodecore.craft_cooking_data()
	nodecore.craft_check(pos, minetest.get_node(pos), data)

	return nodecore.fallcheck(pos)
end
