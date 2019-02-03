-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
		label = "Leaf Decay",
		interval = 1,
		chance = 10,
		limited_max = 100,
		limited_alert = 1000,
		nodenames = {modname .. ":leaves"},
		action = function(pos)
			if not nodecore.scan_flood(pos, 5, function(p)
					if nodecore.match(p, modname .. ":tree") 
					or nodecore.match(p, "ignore") then
						return true
					end
					if nodecore.match(p, modname .. ":leaves") then
						return
					end
					return false
				end) then
				nodecore.leaf_decay(pos)
			end
		end
	})
