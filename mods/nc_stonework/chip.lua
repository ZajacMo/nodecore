-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_craftitem(modname .. ":chip", {
		description = "Stone Chip",
		inventory_image = modname .. "_stone.png",
		wield_image = "[combine:16x16:0,2=" .. modname .. "_stone.png",
		wield_scale = {x = 1.25, y = 1.25, z = 1.75},
		sounds = nc.sounds("nc_terrain_stony")
	})

nc.register_craft({
		label = "break cobble to chips",
		action = "pummel",
		indexkeys = {"nc_terrain:cobble_loose"},
		nodes = {
			{match = "nc_terrain:cobble_loose", replace = "nc_terrain:gravel"}
		},
		items = {
			{name = modname .. ":chip", count = 4, scatter = 5}
		},
		toolgroups = {cracky = 2},
		itemscatter = 5
	})

nc.register_craft({
		label = "break packed cobble to chips",
		action = "pummel",
		indexkeys = {"nc_terrain:cobble"},
		nodes = {
			{match = "nc_terrain:cobble", replace = "nc_terrain:gravel"}
		},
		items = {
			{name = modname .. ":chip", count = 4, scatter = 5}
		},
		toolgroups = {cracky = 4},
		itemscatter = 5
	})

nc.register_craft({
		label = "repack chips to cobble",
		action = "pummel",
		indexkeys = {modname .. ":chip"},
		nodes = {
			{
				match = {name = modname .. ":chip", count = 8},
				replace = "nc_terrain:cobble_loose"
			}
		},
		toolgroups = {thumpy = 2}
	})
