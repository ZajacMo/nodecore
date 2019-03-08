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
