-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

if nodecore.loaded_mods().nc_fire then
	minetest.register_abm({
			label = "flammable stack ignite",
			interval = 5,
			chance = 1,
			nodenames = {"group:is_stack_only"},
			neighbors = {"group:igniter"},
			neighbors_invert = true,
			action_delay = true,
			action = function(pos)
				local stack = nodecore.stack_get(pos)
				return nodecore.fire_check_ignite(pos, {
						name = stack:get_name(),
						count = stack:get_count()
					})
			end
		})
end
