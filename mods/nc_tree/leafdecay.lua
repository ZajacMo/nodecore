-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local cache = {}

local function leafcheck(pos)
	local hash = minetest.hash_node_position(pos)
	local found = cache[hash]
	if found and minetest.get_node(found).name == found.name then return true end
	return nodecore.scan_flood(pos, 5, function(p)
			local n = minetest.get_node(p).name
			if n == modname .. ":tree"
			or n == modname .. ":tree_bud"
			or n == "ignore" then
				while p.prev do
					p.name = minetest.get_node(p).name
					cache[minetest.hash_node_position(p.prev)] = p
					p = p.prev
				end
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
		label = "leaves decay",
		interval = 2,
		chance = 5,
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
		label = "growing leaves decay",
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
