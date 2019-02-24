-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_ore({
		name = "gravel",
		ore_type = "blob",
		ore = modname .. ":gravel",
		wherein = modname .. ":stone",
		clust_size = 5,
		clust_scarcity = 8 * 8 * 8,
		random_factor = 0,
		noise_params = {
			offset  = 0,
			scale   = 3,
			spread  = {x=10, y=25, z=10},
			seed    = 34654,
			octaves = 3,
			persist = 0.5,
			flags = "eased",
		},
		noise_threshold = 1.2	
	})
