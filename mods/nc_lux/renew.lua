-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_soaking_abm({
		label = "lux renew",
		fieldname = "lavalux",
		interval = 10,
		nodenames = {"group:amalgam"},
		arealoaded = 14,
		soakrate = nodecore.lux_soak_rate,
		soakcheck = function(data, pos)
			if data.total < 12500 then return end
			nodecore.set_loud(pos, {name = modname .. ":cobble"
					.. nodecore.lux_react_qty(pos, 1)})
			nodecore.witness(pos, "lux renewal")
		end
	})

nodecore.register_craft({
		label = "lode renew",
		action = "pummel",
		toolgroups = {thumpy = 2},
		normal = {y = 1},
		indexkeys = {"nc_lode:prill_hot"},
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
