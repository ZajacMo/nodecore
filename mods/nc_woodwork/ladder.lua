local modname = minetest.get_current_modname()

local lt = 1/16
local lw = 3/16
local ll = 1/2

local tt = "nc_tree_tree_side.png^(nc_tree_tree_top.png^[mask:nc_woodwork_ladder_mask.png)"

minetest.register_node(modname .. ":ladder", {
		description = "Wooden Ladder",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-lt, -ll, -lt, lt, ll, lt},
			{-lw, -lt, -lt, lw, lt, lt},
			{-lt, -lt, -lw, lt, lt, lw}
		),
		tiles = {tt, tt, "nc_tree_tree_side.png"},
		groups = {
			snappy = 1,
			flammable = 2,
			fire_fuel = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		climbable = true
	})

nodecore.register_craft({
		normal = {x = 1},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{x = -1, match = modname .. ":staff", replace = modname .. ":ladder"},
		}
	})