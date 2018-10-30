local minetest = minetest
local modname = minetest.get_current_modname()

minetest.register_biome({
		name = "unknown",
		node_top = modname .. ":dirt_with_grass",
		depth_top = 1,
		node_filler = modname .. ":dirt",
		depth_filler = 1,
		node_riverbed = modname .. ":sand",
		depth_riverbed = 2,
		y_min = 6,
		y_max = 31000,
		heat_point = 0,
		humidity_point = 0,
	})

minetest.register_biome({
		name = "seabed",
		node_top = modname .. ":sand",
		depth_top = 1,
		node_filler = modname .. ":sand",
		depth_filler = 1,
		node_riverbed = modname .. ":sand",
		depth_riverbed = 2,
		y_min = -31000,
		y_max = 5,
		heat_point = 0,
		humidity_point = 0,
	})