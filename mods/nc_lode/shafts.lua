-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_lode("Bar", {
		["type"] = "node",
		description = "## Lode Bar",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0, 1/8),
		tiles = {modname .. "_#.png"},
		light_source = 1,
		crush_damage = 1,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			falling_repose = 1,
			chisel = 1
		}
	})

nodecore.register_craft({
		label = "anvil making lode bar",
		priority = -1,
		action = "pummel",
		toolgroups = {thumpy = 3},
		indexkeys = {modname .. ":prill_annealed"},
		nodes = {
			{
				match = modname .. ":prill_annealed",
				replace = "air"
			},
			{
				y = -1,
				match = modname .. ":block_tempered"
			}
		},
		items = {
			modname .. ":bar_annealed"
		}
	})

nodecore.register_craft({
		label = "anvil recycle lode bar",
		priority = -1,
		action = "pummel",
		toolgroups = {thumpy = 3},
		normal = {y = 1},
		indexkeys = {modname .. ":bar_annealed"},
		nodes = {
			{
				match = modname .. ":bar_annealed",
				replace = "air"
			},
			{
				y = -1,
				match = modname .. ":block_tempered"
			}
		},
		items = {
			modname .. ":prill_annealed"
		}
	})

nodecore.register_lode("Rod", {
		["type"] = "node",
		description = "## Lode Rod",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		tiles = {modname .. "_#.png"},
		light_source = 2,
		crush_damage = 2,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			falling_repose = 2,
			chisel = 2
		}
	})

nodecore.register_craft({
		label = "anvil making lode rod",
		action = "pummel",
		toolgroups = {thumpy = 3},
		indexkeys = {modname .. ":bar_annealed"},
		nodes = {
			{
				match = {name = modname .. ":bar_annealed"},
				replace = "air"
			},
			{
				y = -1,
				match = {name = modname .. ":bar_annealed"},
				replace = "air"
			},
			{
				y = -2,
				match = modname .. ":block_tempered"
			}
		},
		items = {
			modname .. ":rod_annealed"
		}
	})

nodecore.register_craft({
		label = "recycle lode rod",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":rod_hot"},
		nodes = {
			{
				match = modname .. ":rod_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":bar_hot", count = 2}
		}
	})
