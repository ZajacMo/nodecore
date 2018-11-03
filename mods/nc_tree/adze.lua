local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":adze", {
		description = "Wooden Adze",
		inventory_image = modname .. "_adze.png",
		tool_capabilities = {
			full_punch_interval = 1.2,
			groupcaps = {
				choppy = {times={[3]=1.60}, uses=20, maxlevel=1},
			}
		},
	})

nodecore.staff_tool_recipes[modname .. ":stick"] = modname .. ":adze"
