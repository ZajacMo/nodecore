-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":humus", {
		description = "Humus",
		tiles = {modname .. "_humus.png"},
		groups = {
			dirt = 2,
			crumbly = 1,
			soil = 4,
			soil_not_grass = 1
		},
		alternate_loose = {
			groups = {
				dirt_loose = 2,
				soil = 5,
				soil_not_grass = 1
			}
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})

minetest.register_node(modname .. ":peat", {
		description = "Peat",
		tiles = {modname .. "_humus.png^" .. modname .. "_peat.png^nc_api_loose.png"},
		groups = {
			falling_repose = 1,
			crumbly = 1,
			flammable = 1,
			fire_fuel = 3,
			moist = 1,
			green = 1
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

nodecore.register_craft({
		label = "compress peat block",
		action = "pummel",
		toolgroups = {crumbly = 2},
		nodes = {
			{
				match = {name = modname .. ":leaves_loose", count = 8},
				replace = modname .. ":peat"
			}
		}
	})

nodecore.register_soaking_abm({
		label = "Composting Growing",
		fieldname = "compost",
		nodenames = {modname .. ":peat"},
		neighbors = {"group:soil"},
		interval = 10,
		chance = 1,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = nodecore.tree_soil_rate,
		soakcheck = function(data, pos)
			if data.total < 2500 then return end
			minetest.get_meta(pos):from_table({})
			if math_random(1, 100) == 1 and minetest.get_node_light(
				{x = pos.x, y = pos.y + 1, z = pos.z}) == 15 then
				nodecore.set_loud(pos, {name = "nc_terrain:dirt_with_grass"})
				return
			end
			nodecore.set_loud(pos, {name = modname .. ":humus"})
		end
	})

nodecore.register_dirt_leeching(modname .. ":humus", "nc_terrain:dirt_loose", 3)
