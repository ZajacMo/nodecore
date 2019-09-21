-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local side = "nc_tree_tree_side.png"
local top = side .. "^(" .. modname .. "_plank.png^[mask:"
.. modname .. "_shelf.png)"

minetest.register_node(modname .. ":shelf", {
		description = "Wooden Shelf",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5},
			{-0.5, 7/16, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -7/16, -0.5, -7/16, 7/16, -7/16},
			{-0.5, -7/16, 7/16, -7/16, 7/16, 0.5},
			{7/16, -7/16, -0.5, 0.5, 7/16, -7/16},
			{7/16, -7/16, 7/16, 0.5, 7/16, 0.5}
		),
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		tiles = { top, top, side },
		groups = {
			choppy = 1,
			visinv = 1,
			flammable = 2,
			fire_fuel = 3,
			container = 1,
			totable = 1
		},
		paramtype = "light",
		sounds = nodecore.sounds("nc_tree_woody"),
		on_construct = function(pos)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_size("solo", 1)
			nodecore.visinv_update_ents(pos)
		end,
		on_rightclick = function(pos, _, clicker, stack, pointed_thing)
			if not nodecore.interact(clicker) then return end
			if pointed_thing.above.y ~= pointed_thing.under.y then
				return minetest.item_place_node(stack, clicker, pointed_thing)
			end
			if not stack or stack:is_empty() then return end
			local def = minetest.registered_items[stack:get_name()] or {}
			if def.groups and def.groups.container then
				return minetest.item_place_node(stack, clicker, pointed_thing)
			end
			return nodecore.stack_add(pos, stack)
		end,
		on_punch = function(pos, node, puncher, pointed_thing, ...)
			minetest.node_punch(pos, node, puncher, pointed_thing, ...)
			if not nodecore.interact(puncher) then return end
			if pointed_thing.above.y ~= pointed_thing.under.y then return end
			return nodecore.stack_giveto(pos, puncher)
		end,
		on_dig = function(pos, node, digger, ...)
			if nodecore.stack_giveto(pos, digger) then
				return minetest.node_dig(pos, node, digger, ...)
			end
		end,
		on_ignite = function(pos)
			return nodecore.stack_get(pos)
		end,
		stack_allow = function(_, _, stack)
			local def = minetest.registered_items[stack:get_name()] or {}
			if def.groups and def.groups.container then return false end
		end
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		norotate = true,
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = -1, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = -1, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
		}
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		norotate = true,
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = 0, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 0, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = -1, z = 0, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = 0, match = modname .. ":frame", replace = modname .. ":shelf"},
		}
	})
