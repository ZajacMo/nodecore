-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":rush", {
		description = "Rush",
		drawtype = "plantlike",
		waving = 1,
		tiles = {modname .. "_rush_side.png"},
		inventory_image = modname .. "_rush_inv.png",
		wield_image = modname .. "_rush_inv.png",
		wield_scale = {x = 1.2, y = 1.2, z = 1.2},
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 4,
		sunlight_propagates = true,
		walkable = false,
		groups = {
			snappy = 1,
			flora = 1,
			flammable = 3,
			attached_node = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy"),
		selection_box = {
			type = "fixed",
			fixed = {-6/16, -0.5, -6/16, 6/16, 4/16, 6/16},
		},
	})

minetest.register_decoration({
		name = modname .. ":rush",
		deco_type = "simple",
		place_on = {"group:soil", "nc_terrain:sand"},
		sidelen = 4,
		noise_params = {
			offset = -0.4,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		y_max = 3,
		y_min = 1,
		spawn_by = {"group:moist", modname .. ":rush"},
		num_spawn_by = 1,
		decoration = {modname .. ":rush"},
		param2 = 4,
	})
