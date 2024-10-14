-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":thatch", {
		description = "Thatch",
		tiles = {modname .. "_thatch.png"},
		groups = {
			snappy = 1,
			flammable = 1,
			fire_fuel = 4,
			peat_grindable_node = 1
		},
		sounds = nc.sounds("nc_terrain_grassy"),
		mapcolor = {r = 132, g = 135, b = 87},
	})

nc.register_craft({
		label = "pack thatch",
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = {groups = {flora_sedges = true}, count = 8},
				replace = modname .. ":thatch"
			}
		},
	})

nc.register_craft({
		label = "unpack thatch",
		action = "pummel",
		wield = {groups = {rakey = true}},
		duration = 2,
		consumewield = 1,
		nodes = {
			{
				match = modname .. ":thatch",
				replace = "air"
			}
		},
		items = {
			{name = "nc_flora:sedge_1 2", count = 4, scatter = 5}
		}
	})
