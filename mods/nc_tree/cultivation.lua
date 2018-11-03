-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":eggcorn", {
		description = "EggCorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		collision_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		selection_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		inventory_image = modname .. "_eggcorn.png",
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 3,
			falling_repose = 1
		}
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = modname .. ":eggcorn",
			prob = 0.1 * (node.param2 + 1)}
	end)
