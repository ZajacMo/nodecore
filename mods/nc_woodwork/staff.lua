-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":staff", {
		description = "Staff",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		tiles = {
			"nc_tree_tree_top.png",
			"nc_tree_tree_top.png",
			"nc_tree_tree_side.png"
		},
		paramtype = "light",
		groups = {
			shafty = 1,
			snappy = 2,
			falling_repose = 2
		}
	})
minetest.register_alias("nc_tree:staff", modname .. ":staff")

nodecore.register_craft({
		normal = {y = 1},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = modname .. ":staff"}
		}
	})
