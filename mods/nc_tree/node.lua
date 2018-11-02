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
	})


minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"nc_terrain:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.008,
			scale = 0.012,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"unknown"},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath(modname) .. "/schematics/tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
		replacements = {
			["nc_terrain:tree"] = modname .. ":tree",
			["nc_terrain:leaves"] = modname .. ":leaves",
		}
	})