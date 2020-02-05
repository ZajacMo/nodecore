-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_soaking_abm({
		label = "lux renewal",
		fieldname = "lavalux",
		interval = 10,
		chance = 1,
		nodenames = {"group:amalgam"},
		neighbors = {"group:lux_fluid"},
		soakrate = nodecore.lux_soak_rate,
		soakcheck = function(data, pos)
			if data.total < 12500 then return end
			nodecore.set_loud(pos, {name = modname .. ":cobble"
					.. nodecore.lux_react_qty(pos, 1)})
			nodecore.witness(pos, "lux renewal")
		end
	})

nodecore.register_craft({
		label = "lode renewal",
		action = "pummel",
		toolgroups = {thumpy = 2},
		normal = {y = 1},
		nodes = {
			{
				match = "nc_lode:prill_hot",
				replace = "air"
			},
			{
				y = -1,
				match = modname .. ":cobble8",
				replace = "nc_lode:cobble_hot"
			}
		}
	})
