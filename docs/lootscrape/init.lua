-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()
minetest.after(0, function()
		local coremods = {}
		for k in pairs(nodecore.coremods) do
			coremods[k] = true
		end
		modstore:set_string('*', minetest.write_json(coremods))
	end)
nodecore.register_lbm({
		name = minetest.get_current_modname() .. ":record",
		run_at_every_load = true,
		nodenames = {"group:visinv"},
		action = function(pos)
			local stack = nodecore.stack_get(pos)
			local repl = ItemStack(stack:get_name())
			repl:set_count(stack:get_count())
			modstore:set_string(minetest.pos_to_string(pos), repl:to_string())
		end
	})
