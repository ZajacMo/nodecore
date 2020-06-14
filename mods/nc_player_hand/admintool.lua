-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local supername = modname .. ":super"
minetest.register_node(supername, nodecore.underride({
			description = "HAND OF POWER",
			light_source = 14,
			tiles = {"[combine:1x1^[noalpha^[colorize:#ffffff:255"},
			tool_capabilities = nodecore.toolcaps({
					uses = 0,
					cracky = 100,
					crumbly = 100,
					choppy = 100,
					snappy = 100,
					thumpy = 100
				}),
			virtual_item = true,
			on_drop = function() return ItemStack("") end,
			on_place = function() end
		}, minetest.registered_nodes[modname .. ":hand"]))

minetest.register_chatcommand("nckfa", {
		description = "Summon admin tool",
		privs = {give = true},
		func = function(name)
			minetest.registered_chatcommands.giveme.func(name, supername)
		end
	})
