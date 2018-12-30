-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stick", {
		description = "Stick",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			shafty = 1,
			snappy = 2,
			falling_repose = 1
		}
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = modname .. ":stick",
			prob = 0.2 * (node.param2 * node.param2)}
	end)

minetest.register_node(modname .. ":staff", {
		description = "Staff",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			shafty = 1,
			snappy = 2,
			falling_repose = 2
		}
	})

nodecore.register_craft({
		normal = {y = 1},
		nodes = {
			{match = modname .. ":stick", replace = "air"},
			{y = -1, match = modname .. ":stick", replace = modname .. ":staff"}
		}
	})
