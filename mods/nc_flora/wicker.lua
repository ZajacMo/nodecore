-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":wicker", {
		description = "Wicker",
		drawtype = "glasslike",
		tiles = {modname .. "_wicker.png"},
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 5,
			peat_grindable_node = 1
		},
		paramtype = "light",
		sounds = nc.sounds("nc_tree_sticky"),
		mapcolor = {r = 81, g = 63, b = 45, a = 208},
	})

nc.register_craft({
		label = "pack wicker",
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = {name = "nc_flora:rush_dry", count = 8},
				replace = modname .. ":wicker"
			}
		},
	})

nc.register_craft({
		label = "unpack wicker",
		action = "pummel",
		wield = {groups = {rakey = true}},
		duration = 2,
		consumewield = 1,
		nodes = {
			{
				match = modname .. ":wicker",
				replace = "air"
			}
		},
		items = {
			{name = "nc_flora:rush_dry 2", count = 4, scatter = 5}
		}
	})
