-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":adze", {
		description = "Wooden Adze",
		inventory_image = modname .. "_adze.png",
		groups = {
			flammable = 2
		},
		tool_capabilities = nodecore.toolcaps({
				choppy = 1
			})
	})

nodecore.register_craft({
		label = "assemble wood adze",
		normal = {y = 1},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{y = -1, match = modname .. ":staff", replace = "air"},
		},
		items = {
			{y = -1, name = modname .. ":adze"}
		}
	})
