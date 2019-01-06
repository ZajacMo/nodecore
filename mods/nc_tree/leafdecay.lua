-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
		label = "Leaf Decay",
		interval = 1,
		chance = 10,
		limit_max = 100,
		nodenames = {modname .. ":leaves"},
		action = function(pos)
			if not nodecore.scan_flood(pos, 5, function(p)
					if nodecore.node_is(p, modname .. ":tree") 
					or nodecore.node_is(p, "ignore") then
						return true
					end
					if nodecore.node_is(p, modname .. ":leaves") then
						return
					end
					return false
				end) then
				nodecore.leaf_decay(pos)
			end
		end
	})
