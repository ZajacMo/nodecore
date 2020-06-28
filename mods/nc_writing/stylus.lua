-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stylus", {
		description = "Charcoal Stylus",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		tiles = {
			"nc_fire_coal_4.png",
			"nc_tree_tree_top.png",
			"nc_fire_coal_4.png^[lowpart:25:nc_tree_tree_side.png"
		},
		stack_max = 1,
		place_as_item = true,
		groups = {
			firestick = 1,
			snappy = 1,
			flammable = 1,
		},
		sounds = nodecore.sounds("nc_tree_sticky")
	})

nodecore.register_craft({
		label = "assemble charcoal stylus",
		normal = {y = 1},
		indexkeys = {"nc_fire:lump_coal"},
		nodes = {
			{match = "nc_fire:lump_coal", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = "air"},
		},
		items = {
			{y = -1, name = modname .. ":stylus"}
		}
	})
