-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local adzecaps = nc.toolcaps({
		choppy = 1,
		crumbly = 2
	})
adzecaps.groupcaps.crumbly.uses = adzecaps.groupcaps.choppy.uses

core.register_tool(modname .. ":adze", {
		description = "Wooden Adze",
		inventory_image = modname .. "_adze.png",
		groups = {
			firestick = 2,
			flammable = 2
		},
		tool_capabilities = adzecaps,
		sounds = nc.sounds("nc_tree_sticky")
	})

nc.register_craft({
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
