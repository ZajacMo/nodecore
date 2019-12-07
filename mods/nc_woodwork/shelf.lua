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
		tiles = {top, top, side},
		groups = {
			choppy = 1,
			visinv = 1,
			flammable = 2,
			fire_fuel = 3,
			shelf = 1,
			totable = 1
		},
		paramtype = "light",
		sounds = nodecore.sounds("nc_tree_woody"),
		shelf_access = function(pt) return pt.above.y == pt.under.y end,
		on_ignite = function(pos)
			if minetest.get_node(pos).name == modname .. ":shelf" then
				return nodecore.stack_get(pos)
			end
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
