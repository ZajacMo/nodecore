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
			if not nodecore.scan_flood(pos, 3, function(p)
					local n = minetest.get_node(p).name
					if n == modname .. ":tree"
					or n == "ignore" then
						return true
					end
					if n == modname .. ":leaves" then
						return
					end
					return false
				end) then
				nodecore.leaf_decay(pos)
			end
		end
	})
