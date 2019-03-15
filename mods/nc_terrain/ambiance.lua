-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_ambiance({
		label = "Water Source Ambiance",
		nodenames = {"nc_terrain:water_source"},
		neigbors = {"air"},
		interval = 1,
		chance = 1000,
		sound_name = "nc_terrain_watery",
		sound_gain = 0.05
	})
nodecore.register_ambiance({
		label = "Water Flow Ambiance",
		nodenames = {"nc_terrain:water_flowing"},
		neigbors = {"air"},
		interval = 1,
		chance = 50,
		sound_name = "nc_terrain_watery",
		sound_gain = 0.15
	})

nodecore.register_ambiance({
		label = "Lava Source Ambiance",
		nodenames = {"nc_terrain:lava_source"},
		neigbors = {"air"},
		interval = 1,
		chance = 250,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
nodecore.register_ambiance({
		label = "Lava Flow Ambiance",
		nodenames = {"nc_terrain:lava_flowing"},
		neigbors = {"air"},
		interval = 1,
		chance = 10,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
