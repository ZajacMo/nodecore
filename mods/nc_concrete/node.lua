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
		description = "Tarstone",
		tiles = {"nc_terrain_stone.png^[colorize:#000000:160"},
		groups = {
			cracky = 2
		},
		drop_in_place = "nc_terrain:cobble",
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

nodecore.register_stone_bricks("sandstone", "Sandstone",
	modname .. "_sandstone.png",
	192, 96,
	modname .. ":sandstone",
	{cracky = 1},
	{cracky = 2}
)
nodecore.register_stone_bricks("adobe", "Adobe",
	modname .. "_adobe.png",
	240, 120,
	modname .. ":adobe",
	{cracky = 1},
	{cracky = 2}
)
nodecore.register_stone_bricks("coalstone", "Tarstone",
	"nc_terrain_stone.png^[colorize:#000000:160",
	255, 160,
	modname .. ":coalstone",
	{cracky = 2},
	{cracky = 3}
)
