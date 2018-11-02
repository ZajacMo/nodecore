local minetest = minetest
local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":root", {
		description = "Root",
		tiles = {
			modname .. "_tree_top.png",
			"nc_terrain_dirt.png",
			"nc_terrain_dirt.png^" .. modname .. "_roots.png"
		},
	})

minetest.register_node(modname .. ":tree", {
		description = "Tree",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
	})

minetest.register_node(modname .. ":leaves", {
		description = "Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = { modname .. "_leaves.png" },
		groups = { snappy = 2 },
		alternate_loose = {
			tiles = { modname .. "_leaves_dry.png" },
			walkable = false,
			groups = {
				snappy = 3,
				falling_repose = 1
			}
		}
	})