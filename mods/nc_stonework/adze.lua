-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local adzedef
adzedef = {
	description = "Graveled Adze",
	inventory_image = "nc_woodwork_adze.png^" .. modname .. "_tip_adze.png",
	groups = {
		firestick = 2,
		flammable = 2
	},
	tool_capabilities = nodecore.toolcaps({
			choppy = 2,
			crumbly = 2
		}),
	sounds = nodecore.sounds("nc_tree_sticky"),
	after_use = function(_, who)
		nodecore.toolbreakeffects(who, adzedef)
		return ItemStack("nc_woodwork:adze")
	end
}
minetest.register_tool(modname .. ":adze", adzedef)

nodecore.register_craft({
		label = "assemble graveled adze",
		indexkeys = {"group:gravel"},
		nodes = {
			{match = {groups = {gravel = true}}},
			{y = -1, match = "nc_woodwork:adze", replace = "air"},
		},
		items = {
			{name = modname .. ":adze"}
		}
	})
