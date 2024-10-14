-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

if nc.loaded_mods().nc_fire then
	core.register_abm({
			label = "flammable stack ignite",
			interval = 5,
			chance = 1,
			nodenames = {"group:is_stack_only"},
			neighbors = {"group:igniter"},
			neighbors_invert = true,
			action_delay = true,
			action = function(pos)
				local stack = nc.stack_get(pos)
				return nc.fire_check_ignite(pos, {
						name = stack:get_name(),
						count = stack:get_count()
					})
			end
		})
end
