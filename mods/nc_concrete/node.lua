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

local coaldef = minetest.registered_nodes["nc_fire:coal8"]
local coalparticles = coaldef and function(pos)
	if nodecore.silktouch_digging then return end
	nodecore.digparticles(coaldef, {
			time = 0.05,
			amount = 100,
			minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
			maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
			minvel = {x = -2, y = -2, z = -2},
			maxvel = {x = 2, y = 2, z = 2},
			minacc = {x = 0, y = -8, z = 0},
			maxacc = {x = 0, y = -8, z = 0},
			minexptime = 0.25,
			maxexptime = 0.5,
			collisiondetection = true,
			collision_removal = true,
			minsize = 1,
			maxsize = 6
		})
end
or nil

minetest.register_node(modname .. ":coalstone", {
		description = "Tarstone",
		tiles = {"nc_terrain_stone.png^[colorize:#000000:160"},
		groups = {
			cracky = 2
		},
		drop_in_place = "nc_terrain:cobble",
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony"),
		after_dig_node = coalparticles
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
