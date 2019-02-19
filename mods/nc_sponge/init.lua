-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
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
			return minetest.set_node(pos,
				{name = modname .. ":sponge_wet"})
		end
	})

nodecore.register_limited_abm({
		label = "Sponge Drying in Sunlight",
		interval = 1,
		chance = 20,
		limited_max = 100,
		nodenames = {modname .. ":sponge_wet"},
		action = function(pos)
			local light = minetest.get_node_light({x = pos.x, y = pos.y + 1, z = pos.z})
			if light >= 15 and math_random(1, 10) == 1 then
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
