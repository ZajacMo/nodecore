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
			flammable = 3,
			fire_fuel = 4
		},
		sounds = nodecore.sounds("nc_terrain_grassy")
	})

nodecore.register_craft({
		label = "weave sedges into thatch",
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
		label = "grind thatch into peat",
		action = "pummel",
		priority = -1,
		toolgroups = {crumbly = 2},
		nodes = {
			{match = modname .. ":thatch",
				replace = "nc_tree:peat"}
		}
	})
