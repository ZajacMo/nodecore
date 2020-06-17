-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function leafcheck(pos)
	return nodecore.scan_flood(pos, 5, function(p)
			local n = minetest.get_node(p).name
			if n == modname .. ":tree"
			or n == modname .. ":tree_bud"
			or n == "ignore" then
				return true
			end
			if n == modname .. ":leaves"
			or n == modname .. ":leaves_bud" then
				return
			end
			return false
		end
	)
end

nodecore.register_limited_abm({
		label = "Leaf Decay",
		interval = 2,
		chance = 25,
		limited_max = 100,
		limited_alert = 1000,
		nodenames = {modname .. ":leaves"},
		action = function(pos)
			if not leafcheck(pos) then
				return nodecore.leaf_decay(pos)
			end
		end
	})

nodecore.register_limited_abm({
		label = "Growing Leaf Decay",
		interval = 1,
		chance = 10,
		limited_max = 100,
		limited_alert = 1000,
		nodenames = {modname .. ":leaves_bud"},
		action = function(pos, node)
			if not leafcheck(pos) then
				return nodecore.leaf_decay(pos, {
						name = modname .. ":leaves",
						param = node.param,
						param2 = 0
					})
			end
		end
	})
