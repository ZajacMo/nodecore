-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":staff", {
		description = "Staff",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		oldnames = {"nc_tree:staff"},
		tiles = {
			"nc_tree_tree_top.png",
			"nc_tree_tree_top.png",
			"nc_tree_tree_side.png"
		},
		paramtype = "light",
		groups = {
			shafty = 2,
			snappy = 1,
			flammable = 2,
			falling_repose = 2
		}
	})

nodecore.register_craft({
		normal = {y = 1},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = modname .. ":staff"}
		}
	})

if nodecore.register_stick_fire_starting then
	nodecore.register_stick_fire_starting(modname .. ":staff")
end
