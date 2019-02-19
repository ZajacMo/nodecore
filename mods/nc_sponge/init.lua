-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":sponge", {
		description = "Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname ..".png"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			flammable = 3,
			fire_fuel = 3
		}
	})

minetest.register_node(modname .. ":sponge_wet", {
		description = "Wet Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname ..".png^(nc_terrain_water.png^[opacity:96)"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			coolant = 1,
			falling_node = 1
		}
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
			for _, pos in pairs(minetest.find_nodes_in_area(
					{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
					{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
					{"group:water"})) do
				minetest.remove_node(pos)
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
