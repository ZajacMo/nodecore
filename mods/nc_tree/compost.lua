-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":humus", {
		description = "Humus",
		tiles = {modname .. "_humus.png"},
		groups = {
			dirt = 2,
			crumbly = 1,
			soil = 4
		},
		alternate_loose = {
			groups = {
				dirt_loose = 2,
				soil = 5
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
			minetest.set_node(pos, {name = modname .. ":humus"})
			nodecore.node_sound(pos, "place")
		end
	})

nodecore.register_dirt_leeching(modname .. ":humus", "nc_terrain:dirt_loose", 3)
