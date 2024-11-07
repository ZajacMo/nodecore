-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":stick", {
		description = "Stick",
		drawtype = "nodebox",
		node_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0, 1/8),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			firestick = 1,
			snappy = 1,
			flammable = 2,
			falling_repose = 1,
			stack_as_node = 1,
			optic_opaque = 1,
		},
		sounds = nc.sounds("nc_tree_sticky"),
		mapcolor = {a = 0},
	})

nc.register_leaf_drops(function(_, node, list)
		list[#list + 1] = {
			name = modname .. ":stick",
			prob = 0.2 * (node.param2 * node.param2)}
	end)
