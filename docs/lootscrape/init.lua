-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs
    = ItemStack, core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modstore = core.get_mod_storage()
core.after(0, function()
		local coremods = {}
		for k in pairs(nc.coremods) do
			coremods[k] = true
		end
		modstore:set_string('*', core.write_json(coremods))
	end)
nc.register_lbm({
		name = core.get_current_modname() .. ":record",
		run_at_every_load = true,
		nodenames = {"group:visinv"},
		action = function(pos)
			local stack = nc.stack_get(pos)
			local repl = ItemStack(stack:get_name())
			repl:set_count(stack:get_count())
			modstore:set_string(core.pos_to_string(pos), repl:to_string())
		end
	})
