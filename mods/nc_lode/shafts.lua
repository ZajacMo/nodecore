-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_lode("Bar", {
		["type"] = "node",
		description = "## Lode Bar",
		drawtype = "nodebox",
		node_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0, 1/8),
		tiles = {modname .. "_#.png"},
		light_source = 1,
		crush_damage = 1,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			falling_repose = 1,
			chisel = 1,
			optic_opaque = 1,
		},
		mapcolor = {a = 0},
	})

nc.register_lode_anvil_recipe(-1, function(temper)
		return {
			label = "anvil making lode bar",
			priority = -1,
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":prill_" .. temper},
			nodes = {
				{
					match = modname .. ":prill_" .. temper,
					replace = "air"
				}
			},
			items = {
				modname .. ":bar_" .. temper
			}
		}
	end)

nc.register_lode_anvil_recipe(-1, function(temper)
		return {
			label = "anvil recycle lode bar",
			priority = -1,
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			indexkeys = {modname .. ":bar_" .. temper},
			nodes = {
				{
					match = modname .. ":bar_" .. temper,
					replace = "air"
				}
			},
			items = {
				modname .. ":prill_" .. temper
			}
		}
	end)

nc.register_lode("Rod", {
		["type"] = "node",
		description = "## Lode Rod",
		drawtype = "nodebox",
		node_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		tiles = {modname .. "_#.png"},
		light_source = 2,
		crush_damage = 2,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			falling_repose = 2,
			chisel = 2,
			optic_opaque = 1,
		},
		mapcolor = {a = 0},
	})

nc.register_lode_anvil_recipe(-2, function(temper)
		return {
			label = "anvil making lode rod",
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":bar_" .. temper},
			nodes = {
				{
					match = {name = modname .. ":bar_" .. temper},
					replace = "air"
				},
				{
					y = -1,
					match = {name = modname .. ":bar_" .. temper},
					replace = "air"
				}
			},
			items = {
				modname .. ":rod_" .. temper
			}
		}
	end)

nc.register_craft({
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
