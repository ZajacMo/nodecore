-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":root", {
		description = "Stump",
		tiles = {
			modname .. "_tree_top.png",
			"nc_terrain_dirt.png",
			"nc_terrain_dirt.png^" .. modname .. "_roots.png"
		},
		silktouch = false,
		groups = {
			flammable = 50,
			fire_fuel = 4,
			choppy = 4,
			scaling_time = 80
		},
		drop = "nc_tree:stick 8",
		sounds = nodecore.sounds("nc_tree_woody")
	})

minetest.register_node(modname .. ":log", {
		description = "Log",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		groups = {
			choppy = 2,
			flammable = 8,
			fire_fuel = 6,
			log = 1,
			scaling_time = 75
		},
		sounds = nodecore.sounds("nc_tree_woody"),
		paramtype2 = "facedir",
		on_place = minetest.rotate_node
	})

minetest.register_node(modname .. ":tree", {
		description = "Tree Trunk",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		groups = {
			choppy = 2,
			flammable = 8,
			fire_fuel = 6,
			log = 1,
			falling_node = 1,
			scaling_time = 80
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_tree_woody"),
		drop = modname .. ":log"
	})

nodecore.register_aism({
		label = "tree trunk convert",
		interval = 1,
		chance = 1,
		itemnames = {modname .. ":tree"},
		action = function(stack)
			stack:set_name(modname .. ":log")
			return stack
		end
	})

local function fade(txr)
	return txr .. "^[multiply:#a0a0a0^" .. txr
end

local hashpos = minetest.hash_node_position

minetest.register_node(modname .. ":leaves", {
		description = "Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {fade(modname .. "_leaves.png")},
		waving = 1,
		air_pass = true,
		silktouch = false,
		groups = {
			canopy = 1,
			snappy = 1,
			flammable = 3,
			fire_fuel = 2,
			green = 3,
			scaling_time = 90,
			leaf_decay = 1
		},
		alternate_loose = {
			tiles = {fade(modname .. "_leaves_dry.png")},
			walkable = false,
			groups = {
				canopy = 0,
				leafy = 1,
				flammable = 1,
				falling_repose = 1,
				green = 1,
				stack_as_node = 1,
				leaf_decay = 0,
				peat_grindable_item = 1
			},
			visinv_bulk_optimize = true
		},
		alternate_solid = {
			preserve_metadata = function(pos, _, oldmeta)
				if oldmeta.leaf_decay_forced then
					nodecore.leaf_decay_forced[hashpos(pos)]
					= oldmeta.leaf_decay_forced
				end
			end,
			after_dig_node = function(...)
				return nodecore.leaf_decay(...)
			end,
			node_dig_prediction = "air"
		},
		no_repack = true,
		sounds = nodecore.sounds("nc_terrain_swishy")
	})
nodecore.register_leaf_drops(function(_, _, list)
		list[#list + 1] = {name = modname .. ":leaves_loose", prob = 0.5}
		list[#list + 1] = {name = "air"}
	end)
