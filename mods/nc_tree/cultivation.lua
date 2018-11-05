-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":eggcorn", {
		description = "EggCorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		collision_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		selection_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		inventory_image = modname .. "_eggcorn.png",
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 3,
			falling_repose = 1
		}
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = modname .. ":eggcorn",
			prob = 0.1 * (node.param2 + 1)}
	end)

local ldname = "nc_terrain:dirt_loose"
local epname = modname .. ":eggcorn_planted"
local loosedirt = minetest.registered_nodes[ldname]
local planted = {}
for k, v in pairs(loosedirt) do planted[k] = v end
planted.drop = ldname
minetest.register_node(epname, planted)

minetest.register_abm({
		label = "EggCorn Planting",
		nodenames = {modname .. ":eggcorn"},
		interval = 2,
		chance = 2,
		action = function(pos, node)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if minetest.get_node(above).name ~= ldname then return end
			minetest.remove_node(pos)
			minetest.set_node(above, {name = epname})
			minetest.check_single_for_falling(above)
		end
	})

minetest.register_abm({
		label = "EggCorn Growing",
		nodenames = {epname},
		interval = 10,
		chance = 10,
		action = function(pos, node)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local place = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
			minetest.place_schematic(place, nodecore.tree_schematic, "random", {}, false)
		end
	})
