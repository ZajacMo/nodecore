-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc
    = ItemStack, core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local adzedef
adzedef = {
	description = "Graveled Adze",
	inventory_image = "nc_woodwork_adze.png^" .. modname .. "_tip_adze.png",
	groups = {
		firestick = 2,
		flammable = 2
	},
	tool_capabilities = nc.toolcaps({
			choppy = 2,
			crumbly = 2
		}),
	sounds = nc.sounds("nc_tree_sticky"),
	after_use = function(_, who)
		nc.toolbreakeffects(who, adzedef)
		return ItemStack("nc_woodwork:adze")
	end
}
core.register_tool(modname .. ":adze", adzedef)

nc.register_craft({
		label = "assemble graveled adze",
		action = "stackapply",
		wield = {groups = {gravel = true}},
		consumewield = 1,
		indexkeys = {"nc_woodwork:adze"},
		nodes = {
			{
				match = {
					name = "nc_woodwork:adze",
					wear = 0.05
				}
			},
		},
		items = {
			{name = modname .. ":adze"}
		},
		after = function(pos, data)
			nc.set_loud(pos, {name = data.wield:get_name()})
		end
	})
