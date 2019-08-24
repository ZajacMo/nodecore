-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
	label = "Aggregate Wettening",
	interval = 1,
	chance = 2,
	limited_max = 100,
	nodenames = {modname .. ":aggregate"},
	neighbors = {"group:water"},
	action = function(pos)
		minetest.set_node(pos, {name = modname .. ":wet_source"})
		nodecore.node_sound(pos, "place")
	end
})

nodecore.register_limited_abm({
	label = "Aggregate Wandering",
	interval = 4,
	chance = 2,
	limited_max = 100,
	nodenames = {modname .. ":wet_source"},
	neighbors = {modname .. ":wet_flowing"},
	action = function(pos)
		local found = minetest.find_nodes_in_area(
			vector.add(pos, {x = -1, y = 0, z = -1}),
			vector.add(pos, {x = 1, y = 0, z = 1}),
			{modname .. ":wet_flowing"})
		if #found < 1 then return end
		local newpos = found[math_random(1, #found)]
		minetest.set_node(newpos, {name = modname .. ":wet_source"})
		minetest.set_node(pos, {name = modname .. ":wet_flowing", param2 = 7})
		nodecore.node_sound(newpos, "place")
	end
})

nodecore.register_limited_abm({
	label = "Aggregate Hardening",
	interval = 4,
	chance = 15,
	limited_max = 100,
	nodenames = {modname .. ":wet_source"},
	neighbors = {"air"},
	action = function(pos)
		if minetest.find_node_near(pos, 1, {"group:wet"}) then return end
		minetest.set_node(pos, {name = "nc_terrain:stone"})
		nodecore.node_sound(pos, "place")
	end
})
