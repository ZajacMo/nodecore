-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"nc_terrain:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.008,
			scale = 0.016,
			spread = {x = 120, y = 120, z = 120},
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
		replacements = {}
	})
