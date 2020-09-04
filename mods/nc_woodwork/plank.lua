-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local plank = modname .. ":plank"
minetest.register_node(plank, {
		description = "Wooden Plank",
		tiles = {modname .. "_plank.png"},
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
		check = function(_, data)
			return nodecore.facedirs[data.node.param2].t.y == 1
		end,
		indexkeys = {"group:log"},
		nodes = {
			{match = {groups = {log = true}}, replace = "air"}
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
		indexkeys = {plank},
		nodes = {
			{match = plank, replace = "air"}
		},
		items = {
			{name = "nc_tree:stick 2", count = 4, scatter = 5}
		}
	})
