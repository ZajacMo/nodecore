-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local adzecaps = nodecore.toolcaps({
		choppy = 1,
		crumbly = 2
	})
adzecaps.groupcaps.crumbly.uses = adzecaps.groupcaps.choppy.uses

minetest.register_tool(modname .. ":adze", {
		description = "Adze",
		inventory_image = modname .. "_adze.png",
		groups = {
			firestick = 2,
			flammable = 2
		},
		tool_capabilities = adzecaps,
		sounds = nodecore.sounds("nc_tree_sticky")
	})

nodecore.register_craft({
		label = "assemble wood adze",
		normal = {y = 1},
		indexkeys = {"nc_tree:stick"},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{y = -1, match = modname .. ":staff", replace = "air"},
		},
		items = {
			{y = -1, name = modname .. ":adze"}
		}
	})
