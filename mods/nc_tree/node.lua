-- LUALOCALS < ---------------------------------------------------------
local math, minetest, type
    = math, minetest, type
local math_random
    = math.random
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
				node = node or minetest.get_node(node)
				local l = modname .. ":leaves_loose"
				local e = modname .. ":eggcorn"
				local b = modname .. ":stick"
				local p = {l, l, l, l, l, l, l, l, b, b, e}
				if node.param2 > 0 then
					p[#p + 1] = e
					p[#p + 1] = e
				end
				if node.param2 > 1 then
					p[#p + 1] = b
					p[#p + 1] = b
					p[#p + 1] = b
					p[#p + 1] = b
				end
				minetest.place_node(pos,
					{name = p[math_random(1, #p)]})
			end
		}
	})

local function fixed(t) return {type = "fixed", fixed = t} end
minetest.register_node(modname .. ":eggcorn", {
		description = "EggCorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		collision_box = fixed({-3/16, -0.5, -3/16, 3/16, 0, 3/16}),
		selection_box = fixed({-3/16, -0.5, -3/16, 3/16, 0, 3/16}),
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 3,
			falling_repose = 1
		}
	})

minetest.register_node(modname .. ":stick", {
		drawtype = "nodebox",
		node_box = fixed({-1/16, -0.5, -1/16, 1/16, 0, 1/16}),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			snappy = 2,
			falling_repose = 1
		}
	})

minetest.register_node(modname .. ":staff", {
		drawtype = "nodebox",
		node_box = fixed({-1/16, -0.5, -1/16, 1/16, 0.5, 1/16}),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			snappy = 2,
			falling_repose = 1
		}
	})
