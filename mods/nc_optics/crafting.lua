-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "hammer prism from glass",
		action = "pummel",
		toolgroups = {thumpy = 5},
		nodes = {
			{
				match = modname .. ":glass_opaque",
				replace = modname .. ":prism"
			}
		}
	})

nodecore.register_craft({
		label = "cleave lenses from glass",
		action = "pummel",
		toolgroups = {choppy = 5},
		nodes = {
			{
				match = modname .. ":glass_opaque",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":lens", count = 2, scatter = 5}
		}
	})

nodecore.register_craft({
		label = "hammer glass to crude",
		action = "pummel",
		priority = -1,
		toolgroups = {thumpy = 3},
		nodes = {
			{
				match = {groups = {silica_clear = true, visinv = false}},
				replace = modname .. ":glass_crude"
			}
		}
	})

nodecore.register_craft({
		label = "hammer tank to crude",
		action = "pummel",
		priority = -1,
		toolgroups = {thumpy = 3},
		check = function(pos) return nodecore.stack_get(pos):is_empty() end,
		nodes = {
			{
				match = modname .. ":shelf",
				replace = modname .. ":glass_crude"
			}
		}
	})

nodecore.register_craft({
		label = "hammer glass back to sand",
		action = "pummel",
		priority = -2,
		toolgroups = {thumpy = 3},
		nodes = {
			{
				match = {groups = {silica = true, silica_molten = false, silica_lens = false, visinv = false}},
				replace = "nc_terrain:sand_loose"
			}
		}
	})

nodecore.register_craft({
		label = "hammer lenses back to sand",
		action = "pummel",
		toolgroups = {thumpy = 3},
		nodes = {
			{
				match = {groups = {silica_lens = true}, count = 2},
				replace = "nc_terrain:sand_loose"
			}
		}
	})
