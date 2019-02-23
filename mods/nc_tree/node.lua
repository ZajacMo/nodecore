-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":root", {
		description = "Root",
		tiles = {
			modname .. "_tree_top.png",
			"nc_terrain_dirt.png",
			"nc_terrain_dirt.png^" .. modname .. "_roots.png"
		},
		groups = {
			flammable = 50,
			fire_fuel = 4
		}
	})

minetest.register_node(modname .. ":tree", {
		description = "Tree",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		groups = {
			choppy = 2,
			flammable = 5,
			fire_fuel = 6
		}
	})

minetest.register_node(modname .. ":leaves", {
		description = "Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = { modname .. "_leaves.png" },
		groups = {
			snappy = 1,
			flammable = 3,
			fire_fuel = 2,
			green = 3
		},
		alternate_loose = {
			tiles = { modname .. "_leaves_dry.png" },
			walkable = false,
			groups = {
				flammable = 1,
				falling_repose = 1,
				green = 1
			}
		},
		alternate_solid = {
			after_dig_node = function(...)
				return nodecore.leaf_decay(...)
			end
		}
	})
nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {name = modname .. ":leaves_loose", prob = 0.5}
		list[#list + 1] = {name = "air"}
	end)

local function fixed(t) return {type = "fixed", fixed = t} end
