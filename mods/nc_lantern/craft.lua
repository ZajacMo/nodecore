-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "assemble lantern",
		normal = {x = 1},
		indexkeys = {"nc_optics:glass_opaque"},
		nodes = {
			{match = "nc_optics:glass_opaque", replace = "air"},
			{x = -1, match = "nc_tote:handle", replace = "air"},
		},
		items = {
			{name = modname .. ":lamp0"}
		}
	})

nodecore.register_craft({
		label = "break apart lantern",
		action = "pummel",
		toolgroups = {choppy = 5},
		indexkeys = {"group:" .. modname},
		nodes = {
			{
				match = {groups = {[modname] = true}},
				replace = "air"
			}
		},
		items = {
			{name = "nc_lode:bar_annealed 2", count = 4, scatter = 5},
			{name = "nc_optics:glass_crude", scatter = 5}
		}
	})
