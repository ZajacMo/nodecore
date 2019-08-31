-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
		label = "Sponge Growth",
		interval = 10,
		chance = 1000,
		limited_max = 100,
		nodenames = {"group:water"},
		neighbors = {modname .. ":sponge_living"},
		action = function(pos)
			if minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name
			~= "nc_terrain:sand" then return end
			minetest.set_node(pos, {name = modname .. ":sponge_living"})
		end
	})

nodecore.register_limited_abm({
		label = "Sponge Wettening",
		interval = 1,
		chance = 10,
		limited_max = 100,
		nodenames = {modname .. ":sponge"},
		neighbors = {"group:water"},
		action = function(pos)
			minetest.set_node(pos, {name = modname .. ":sponge_wet"})
			nodecore.node_sound(pos, "place")
			for _, p in pairs(minetest.find_nodes_in_area(
					{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
					{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
					{"group:water"})) do
				nodecore.node_sound(p, "dig")
				minetest.remove_node(p)
			end
		end
	})

nodecore.register_limited_abm({
		label = "Sponge Drying in Sunlight",
		interval = 1,
		chance = 100,
		limited_max = 100,
		nodenames = {modname .. ":sponge_wet"},
		action = function(pos)
			if minetest.get_node_light({x = pos.x, y = pos.y + 1, z = pos.z}) >= 15 then
				return minetest.set_node(pos, {name = modname .. ":sponge"})
			end
		end
	})

nodecore.register_limited_abm({
		label = "Sponge Drying near Fire",
		interval = 1,
		chance = 20,
		limited_max = 100,
		nodenames = {modname .. ":sponge_wet"},
		neighbors = {"group:igniter"},
		action = function(pos)
			return minetest.set_node(pos, {name = modname .. ":sponge"})
		end
	})
