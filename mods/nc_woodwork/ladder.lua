-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local lt = 1/16
local lw = 3/16
local ll = 1/2
local lf = 1/8

local tt = "nc_woodwork_frame.png^(nc_tree_tree_top.png^[mask:nc_woodwork_ladder_mask.png)"

minetest.register_node(modname .. ":ladder", {
		description = "Wooden Ladder",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-lt, -ll, -lt, lt, ll, lt},
			{-lw, -lt, -lt, lw, lt, lt},
			{-lt, -lt, -lw, lt, lt, lw}
		),
		selection_box = nodecore.fixedbox(-lw, -ll, -lw, lw, ll, lw),
		tiles = {tt},
		groups = {
			snappy = 1,
			flammable = 2,
			fire_fuel = 1,
			falling_node = 1,
			optic_opaque = 1,
		},
		crush_damage = 0.25,
		paramtype = "light",
		sunlight_propagates = true,
		climbable = true,
		sounds = nodecore.sounds("nc_tree_sticky"),
		mapcolor = {r = 79, g = 54, b = 31, a = 64},

	})

nodecore.register_craft({
		label = "assemble wood ladder",
		normal = {x = 1},
		indexkeys = {"nc_tree:stick"},
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
		selection_box = nodecore.fixedbox(
			{-lf, -ll, -lf, lf, ll, lf},
			{-ll, -lf, -lf, ll, lf, lf},
			{-lf, -lf, -ll, lf, lf, ll}
		),
		tiles = {tt},
		groups = {
			snappy = 1,
			flammable = 2,
			fire_fuel = 1,
			optic_opaque = 1,
		},
		paramtype = "light",
		climbable = true,
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_tree_sticky"),
		mapcolor = {r = 79, g = 54, b = 31, a = 128},
	})

nodecore.register_craft({
		label = "assemble wood frame",
		normal = {x = 1},
		indexkeys = {modname .. ":staff"},
		nodes = {
			{match = modname .. ":staff", replace = "air"},
			{x = -1, match = modname .. ":staff", replace = modname .. ":frame"},
		}
	})
