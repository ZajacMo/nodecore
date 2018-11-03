-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, type
    = ipairs, minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":root", {
		description = "Root",
		tiles = {
			modname .. "_tree_top.png",
			"nc_terrain_dirt.png",
			"nc_terrain_dirt.png^" .. modname .. "_roots.png"
		},
	})

minetest.register_node(modname .. ":tree", {
		description = "Tree",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		groups = {
			choppy = 3
		},
		drop = modname .. ":log"
	})

minetest.register_node(modname .. ":log", {
		description = "Tree",
		paramtype2 = "facedir",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		groups = {
			choppy = 4,
			falling_node = 1
		},
		on_place = minetest.rotate_and_place
	})

minetest.register_node(modname .. ":leaves", {
		description = "Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = { modname .. "_leaves.png" },
		groups = { snappy = 2 },
		alternate_loose = {
			tiles = { modname .. "_leaves_dry.png" },
			walkable = false,
			groups = {
				snappy = 3,
				falling_repose = 1
			}
		},
		alternate_solid = {
			after_dig_node = function(pos, node)
				node = node or minetest.get_node(pos)
				local t = {}
				for i, v in ipairs(nodecore.registered_leaf_drops) do
					t = v(pos, node, t) or t
				end
				local p = nodecore.pickrand(t, function(x) return x.prob end)
				if not p then return end
				minetest.place_node(pos, p)
			end
		}
	})
nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {name = modname .. ":leaves_loose"}
	end)

local function fixed(t) return {type = "fixed", fixed = t} end

