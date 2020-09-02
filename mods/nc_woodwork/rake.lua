-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local rakable = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.falling_node and v.groups.snappy == 1 then
				rakable[k] = true
			end
		end
	end)

minetest.register_tool(modname .. ":rake", {
		description = "Rake",
		inventory_image = modname .. "_rake.png",
		tool_capabilities = nodecore.toolcaps({
				snappy = 1,
				uses = 10
			}),
		groups = {flammable = 1},
		sounds = nodecore.sounds("nc_tree_sticky"),
		rake_check = function(itemname)
			return rakable[itemname]
		end
	})

local adze = {name = modname .. ":adze", wear = 0.05}
nodecore.register_craft({
		label = "assemble rake",
		norotate = true,
		indexkeys = {"nc_tree:stick"},
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{x = 0, z = -1, match = adze, replace = "air"},
			{x = 0, z = 1, match = adze, replace = "air"},
			{x = -1, z = 0, match = adze, replace = "air"},
			{x = 1, z = 0, match = adze, replace = "air"},
		},
		items = {
			modname .. ":rake"
		}
	})
