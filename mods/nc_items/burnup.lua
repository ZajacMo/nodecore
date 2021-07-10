-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

if nodecore.loaded_mods().nc_fire then
	minetest.register_abm({
			label = "flammable stack ignite",
			interval = 5,
			chance = 1,
			nodenames = {modname .. ":stack"},
			neighbors = {"group:igniter"},
			neighbors_invert = true,
			action = function(pos)
				local stack = nodecore.stack_get(pos)
				return nodecore.fire_check_ignite(pos, {
						name = stack:get_name(),
						count = stack:get_count()
					})
			end
		})
end
