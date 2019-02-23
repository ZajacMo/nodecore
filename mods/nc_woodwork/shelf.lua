-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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
		selection_box = nodecore.fixedbox(
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		),
		tiles = { "nc_tree_tree_side.png^(" .. modname ..
			"_plank.png^[mask:" .. modname .. "_shelf.png)" },
		groups = {
			choppy = 1,
			visinv = 1,
			flammable = 2,
			fire_fuel = 3,
			eject_inv_on_burn = 1
		},
		paramtype = "light",
		on_construct = function(pos)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_size("solo", 1)
			nodecore.visinv_update_ents(pos)
		end,
		on_rightclick = function(pos, node, clicker, stack, pointed_thing)
			if not stack or stack:is_empty() then return end
			return nodecore.stack_add(pos, stack)
		end,
		on_punch = function(pos, node, puncher)
			return nodecore.stack_giveto(pos, puncher)
		end,
		on_dig = function(pos, node, digger, ...)
			if nodecore.stack_giveto(pos, digger) then
				return minetest.node_dig(pos, node, digger, ...)
			end
		end
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = -1, z = -1, match = modname .. ":frame", replace = "air"},
			{x = 1, z = -1, match = modname .. ":frame", replace = "air"},
			{x = -1, z = 1, match = modname .. ":frame", replace = "air"},
			{x = 1, z = 1, match = modname .. ":frame", replace = "air"},
		},
		items = {
			modname .. ":shelf 2"
		}
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = 0, z = -1, match = modname .. ":frame", replace = "air"},
			{x = 0, z = 1, match = modname .. ":frame", replace = "air"},
			{x = -1, z = 0, match = modname .. ":frame", replace = "air"},
			{x = 1, z = 0, match = modname .. ":frame", replace = "air"},
		},
		items = {
			modname .. ":shelf 2"
		}
	})
