-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":adze", {
		description = "Wooden Adze",
		inventory_image = modname .. "_adze.png",
		tool_capabilities = {
			full_punch_interval = 1.2,
			groupcaps = {
				choppy = {times={[3]=6.00, [4]=3.00}, uses=5, maxlevel=1},
			}
		},
	})

nodecore.staff_tool_recipes["nc_tree:stick"] = modname .. ":adze"
