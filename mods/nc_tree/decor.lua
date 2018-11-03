-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, minetest
    = error, ipairs, minetest
-- LUALOCALS > ---------------------------------------------------------

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
		schematic = nodecore.tree_schematic,
		flags = "place_center_x, place_center_z",
		rotation = "random",
		replacements = { }
	})
