-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":sandstone", {
		description = "Sandstone",
		tiles = {modname .. "_sandstone.png"},
		groups = {
			cracky = 1
		},
		drop_in_place = "nc_terrain:sand",
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

minetest.register_node(modname .. ":adobe", {
		description = "Adobe",
		tiles = {modname .. "_adobe.png"},
		groups = {
			cracky = 1
		},
		drop_in_place = "nc_terrain:dirt",
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

minetest.register_node(modname .. ":coalstone", {
		description = "Bituminous Stone",
		tiles = {"nc_terrain_stone.png^[colorize:#000000:128"},
		groups = {
			cracky = 1
		},
		drop_in_place = "nc_terrain:cobble",
		drop = "nc_fire:lump_coal",
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})
