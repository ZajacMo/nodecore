-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":thatch", {
		description = "Thatch",
		tiles = {modname .. "_thatch.png"},
		groups = {
			snappy = 1,
			flammable = 1,
			fire_fuel = 4,
			peat_grindable_node = 1
		},
		sounds = nodecore.sounds("nc_terrain_grassy")
	})

nodecore.register_craft({
		label = "pack thatch",
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = {groups = {flora_sedges = true}, count = 8},
				replace = modname .. ":thatch"
			}
		},
	})

nodecore.register_craft({
		label = "unpack thatch",
		action = "pummel",
		wield = {groups = {rakey = true}},
		duration = 2,
		consumewield = 1,
		nodes = {
			{
				match = modname .. ":thatch",
				replace = "air"
			}
		},
		items = {
			{name = "nc_flora:sedge_1 2", count = 4, scatter = 5}
		}
	})
