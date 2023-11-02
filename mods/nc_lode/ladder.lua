-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local lt = 1/16
local lw = 3/16
local ll = 1/2
local lf = 1/8

nodecore.register_lode("Ladder", {
		["type"] = "node",
		description = "## Lode Ladder",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-lt, -ll, -lt, lt, ll, lt},
			{-lw, -lt, -lt, lw, lt, lt},
			{-lt, -lt, -lw, lt, lt, lw}
		),
		selection_box = nodecore.fixedbox(-lw, -ll, -lw, lw, ll, lw),
		tiles = {modname .. "_#.png"},
		light_source = 2,
		crush_damage = 3,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			falling_node = 1,
			chisel = 2,
			optic_opaque = 1,
		},
		climbable = true
	})

nodecore.register_lode_anvil_recipe({x = 1, y = -1}, function(temper)
		return {
			label = "anvil making lode ladder",
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":bar_" .. temper},
			nodes = {
				{
					match = {name = modname .. ":bar_" .. temper},
					replace = "air"
				},
				{
					x = 1,
					match = {name = modname .. ":rod_" .. temper},
					replace = "air"
				}
			},
			items = {{
					x = 1,
					name = modname .. ":ladder_" .. temper
			}}
		}
	end)

nodecore.register_craft({
		label = "recycle lode ladder",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":ladder_hot"},
		nodes = {
			{
				match = modname .. ":ladder_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":rod_hot"},
			{name = modname .. ":bar_hot"}
		}
	})

nodecore.register_lode("Frame", {
		["type"] = "node",
		description = "## Lode Frame",
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
		tiles = {modname .. "_#.png"},
		light_source = 2,
		crush_damage = 4,
		groups = {
			optic_opaque = 1,
		},
		paramtype = "light",
		sunlight_propagates = true,
		climbable = true
	})

nodecore.register_lode_anvil_recipe({x = 1, y = -1}, function(temper)
		return {
			label = "anvil making lode frame",
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":rod_" .. temper},
			nodes = {
				{
					match = {name = modname .. ":rod_" .. temper},
					replace = "air"
				},
				{
					x = 1,
					match = {name = modname .. ":rod_" .. temper},
					replace = "air"
				}
			},
			items = {{
					x = 1,
					name = modname .. ":frame_" .. temper
			}}
		}
	end)

nodecore.register_craft({
		label = "recycle lode frame",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":frame_hot"},
		nodes = {
			{
				match = modname .. ":frame_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":rod_hot", count = 2},
		}
	})
