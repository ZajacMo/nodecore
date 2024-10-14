-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_biome({
		name = "unknown",
		node_top = modname .. ":dirt_with_grass",
		depth_top = 1,
		node_filler = modname .. ":dirt",
		depth_filler = 2,
		node_riverbed = modname .. ":sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = 31000,
		heat_point = 0,
		humidity_point = 0,
	})

core.register_biome({
		name = "seabed",
		node_top = modname .. ":sand",
		depth_top = 1,
		node_filler = modname .. ":sand",
		depth_filler = 1,
		node_riverbed = modname .. ":sand",
		depth_riverbed = 2,
		y_min = -79,
		y_max = 3,
		heat_point = 0,
		humidity_point = 0,
	})

core.register_biome({
		name = "deep",
		depth_top = 0,
		depth_filler = 0,
		depth_riverbed = 0,
		y_min = -31000,
		y_max = -80,
		heat_point = 0,
		humidity_point = 0,
	})
