-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":wicker", {
		description = "Wicker",
		drawtype = "glasslike",
		tiles = {modname .. "_wicker.png"},
		groups = {
			choppy = 2,
			flammable = 2,
			fire_fuel = 5
		},
		paramtype = "light",
		sounds = nodecore.sounds("nc_tree_sticky")
	})

nodecore.register_craft({
		label = "weave dry rushes into wicker",
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = {name = "nc_flora:rush_dry", count = 8},
				replace = modname .. ":wicker"
			}
		},
	})

nodecore.register_craft({
		label = "grind wicker into peat",
		action = "pummel",
		priority = -1,
		toolgroups = {crumbly = 3},
		nodes = {
			{match = modname .. ":wicker",
				replace = "nc_tree:peat"}
		}
	})
