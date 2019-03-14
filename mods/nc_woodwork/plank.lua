-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local plank = modname .. ":plank"
minetest.register_node(plank, {
		description = "Wooden Plank",
		tiles = { modname .. "_plank.png" },
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 5
		},
		sounds = nodecore.sounds("nc_tree_woody")
	})

nodecore.register_craft({
		label = "split tree to planks",
		action = "pummel",
		toolgroups = {choppy = 1},
		normal = {y = 1},
		nodes = {
			{match = "nc_tree:tree", replace = "air"}
		},
		items = {
			{name = plank, count = 4, scatter = 5}
		}
	})

nodecore.register_craft({
		label = "bash planks to sticks",
		action = "pummel",
		toolgroups = {thumpy = 3},
		normal = {y = 1},
		nodes = { 
			{match = plank, replace = "air"}
		},
		items = {
			{name = "nc_tree:stick", count = 8, scatter = 5}
		}
	})
