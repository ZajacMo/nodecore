-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local rakevol = nodecore.rake_volume(2, 1)
local raketest = nodecore.rake_index(function(def)
		return def.groups and def.groups.falling_node
		and def.groups.snappy == 1
	end)

minetest.register_tool(modname .. ":rake", {
		description = "Wooden Rake",
		inventory_image = modname .. "_rake.png",
		tool_capabilities = nodecore.toolcaps({
				snappy = 1,
				uses = 10
			}),
		groups = {
			flammable = 1,
			rakey = 1,
			nc_doors_pummel_first = 1
		},
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_rake = function() return rakevol, raketest end
	})

local adze = {name = modname .. ":adze", wear = 0.05}
nodecore.register_craft({
		label = "assemble rake",
		indexkeys = {modname .. ":adze"},
		nodes = {
			{match = adze, replace = "air"},
			{y = -1, match = modname .. ":staff", replace = "air"},
			{x = -1, match = adze, replace = "air"},
			{x = 1, match = adze, replace = "air"},
		},
		items = {{
				y = -1,
				name = modname .. ":rake"
		}}
	})
