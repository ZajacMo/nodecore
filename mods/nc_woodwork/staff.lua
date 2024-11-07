-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":staff", {
		description = "Staff",
		drawtype = "nodebox",
		node_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		oldnames = {"nc_tree:staff"},
		tiles = {
			"nc_tree_tree_top.png",
			"nc_tree_tree_top.png",
			"nc_woodwork_frame.png"
		},
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			firestick = 2,
			snappy = 1,
			flammable = 2,
			falling_repose = 2,
			optic_opaque = 1,
		},
		sounds = nc.sounds("nc_tree_sticky"),
		mapcolor = {a = 0},
	})

nc.register_craft({
		label = "assemble staff",
		normal = {y = 1},
		indexkeys = {"nc_tree:stick"},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = modname .. ":staff"}
		}
	})
