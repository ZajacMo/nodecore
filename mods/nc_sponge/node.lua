-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":sponge", {
		description = "Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname ..".png"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			flammable = 3,
			fire_fuel = 3,
			sponge = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

minetest.register_node(modname .. ":sponge_wet", {
		description = "Wet Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname ..".png^(nc_terrain_water.png^[opacity:96)"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			coolant = 1,
			falling_node = 1,
			moist = 1,
			sponge = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

minetest.register_node(modname .. ":sponge_living", {
		description = "Living Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname ..".png^(nc_terrain_water.png^[opacity:96)"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			coolant = 1,
			moist = 1,
			sponge = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy")
	})
