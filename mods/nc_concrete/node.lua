-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":sandstone", {
		description = "Sandstone",
		tiles = {modname .. "_sandstone.png"},
		groups = {
			cracky = 1,
			sandstone = 1
		},
		drop_in_place = "nc_terrain:sand",
		crush_damage = 2,
		sounds = nc.sounds("nc_terrain_stony"),
		mapcolor = {r = 160, g = 161, b = 89},
	})

core.register_node(modname .. ":adobe", {
		description = "Adobe",
		tiles = {modname .. "_adobe.png"},
		groups = {
			cracky = 1,
			adobe = 1
		},
		drop_in_place = "nc_terrain:dirt",
		crush_damage = 1,
		sounds = nc.sounds("nc_terrain_stony"),
		mapcolor = {r = 57, g = 43, b = 28},
	})

core.register_node(modname .. ":cloudstone", {
		description = "Cloudstone",
		tiles = {modname .. "_cloudstone.png"},
		groups = {
			cracky = 1,
			cloudstone = 1
		},
		drop_in_place = "nc_optics:glass_crude",
		crush_damage = 1,
		sounds = nc.sounds("nc_terrain_stony"),
		mapcolor = {r = 220, g = 220, b = 220},
	})

local coaldef = core.registered_nodes["nc_fire:coal8"]
local coalparticles = coaldef and function(pos)
	if nc.silktouch_digging then return end
	nc.digparticles(coaldef, {
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

core.register_node(modname .. ":coalstone", {
		description = "Tarstone",
		tiles = {"nc_terrain_stone.png^[colorize:#000000:160"},
		groups = {
			cracky = 2,
			coalstone = 1
		},
		drop_in_place = "nc_terrain:cobble",
		crush_damage = 2,
		sounds = nc.sounds("nc_terrain_stony"),
		after_dig_node = coalparticles,
		mapcolor = {r = 32, g = 32, b = 32},
	})

nc.register_stone_bricks("sandstone", "Sandstone",
	modname .. "_sandstone.png",
	192, 96,
	modname .. ":sandstone",
	{cracky = 1},
	{cracky = 2},
	{r = 160, g = 161, b = 89}
)
nc.register_stone_bricks("adobe", "Adobe",
	modname .. "_adobe.png",
	240, 120,
	modname .. ":adobe",
	{cracky = 1},
	{cracky = 2, nc_door_scuff_opacity = 16},
	{r = 57, g = 43, b = 28}
)
nc.register_stone_bricks("coalstone", "Tarstone",
	"nc_terrain_stone.png^[colorize:#000000:160",
	255, 160,
	modname .. ":coalstone",
	{cracky = 2},
	{
		cracky = 3,
		nc_door_scuff_opacity = 16,
		door_operate_sound_volume = 150
	},
	{r = 32, g = 32, b = 32}
)
nc.register_stone_bricks("cloudstone", "Cloudstone",
	modname .. "_cloudstone.png",
	128, 64,
	modname .. ":cloudstone",
	{cracky = 2},
	{
		cracky = 3,
		nc_door_scuff_opacity = 96,
		door_operate_sound_volume = 25
	},
	{r = 220, g = 220, b = 220}
)
