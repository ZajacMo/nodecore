local minetest = minetest
local modname = minetest.get_current_modname()

minetest.register_decoration({
		deco_type = "schematic",
		place_on = {modname .. ":dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.016,
			scale = 0.022,
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
	})