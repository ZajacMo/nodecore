-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_craftitem(modname .. ":chip", {
		description = "Stone Chip",
		inventory_image = modname .. "_stone.png"
	})

nodecore.register_craft({
		label = "break cobble to chips",
		action = "pummel",
		nodes = {
			{match = "nc_terrain:cobble_loose", replace = "air"}
		},
		items = {
			{name = modname .. ":chip", count = 8, scatter = 5}
		},
		toolgroups = {cracky = 2},
		itemscatter = 5
	})

nodecore.register_craft({
		label = "repack chips to cobble",
		action = "pummel",
		nodes = {
			{
				match = {name = modname .. ":chip", count = 8},
				replace = "nc_terrain:cobble_loose"
			}
		},
		toolgroups = {thumpy = 2}
	})
