-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

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
		tiles = {tt},
		groups = {
			snappy = 1,
			flammable = 2,
			fire_fuel = 1,
			falling_node = 1,
			stack_as_node = 1
		},
		crush_damage = 0.25,
		paramtype = "light",
		sunlight_propagates = true,
		climbable = true,
		sounds = nodecore.sounds("nc_tree_sticky")

	})

nodecore.register_craft({
		label = "assemble wood ladder",
		normal = {x = 1},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{x = -1, match = modname .. ":staff", replace = modname .. ":ladder"},
		}
	})

minetest.register_node(modname .. ":frame", {
		description = "Wooden Frame",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-lt, -ll, -lt, lt, ll, lt},
			{-ll, -lt, -lt, ll, lt, lt},
			{-lt, -lt, -ll, lt, lt, ll}
		),
		tiles = {tt},
		groups = {
			snappy = 1,
			flammable = 2,
			fire_fuel = 1,
		},
		paramtype = "light",
		climbable = true,
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_tree_sticky")
	})

nodecore.register_craft({
		label = "assemble wood frame",
		normal = {x = 1},
		nodes = {
			{match = modname .. ":staff", replace = "air"},
			{x = -1, match = modname .. ":staff", replace = modname .. ":frame"},
		}
	})
