-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random, math_sqrt
    = math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":eggcorn", {
		description = "EggCorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		collision_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		selection_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		inventory_image = "[combine:24x24:4,4=" .. modname .. "_eggcorn.png",
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 1,
			flammable = 3,
			attached_node = 1
		}
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = "air",
			item = modname .. ":eggcorn",
			prob = 0.05 * (node.param2 + 1)}
	end)

local ldname = "nc_terrain:dirt_loose"
local epname = modname .. ":eggcorn_planted"
minetest.register_node(epname, nodecore.underride({drop = ldname},
		minetest.registered_nodes[ldname]))

nodecore.register_craft({
		label = "eggcorn planting",
		normal = {y = 1},
		nodes = {
			{match = "nc_terrain:dirt_loose", replace = "air"},
			{
				y = -1,
				match = modname .. ":eggcorn",
				replace = modname .. ":eggcorn_planted"
			},
		}
	})

nodecore.register_limited_abm({
		label = "EggCorn Growing",
		nodenames = {epname},
		interval = 10,
		chance = 1,
		action = function(pos, node)
			local meta = minetest.get_meta(pos)
			local d = 0
			local w = 1
			nodecore.scan_flood(pos, 3, function(p)
					local nn = minetest.get_node(p).name
					local def = minetest.registered_nodes[nn]
					if not def or not def.groups then
						return false
					end
					if def.groups.soil then
						d = d + def.groups.soil
						w = w + 0.2
					elseif def.groups.water then
						w = w + def.groups.water
						return false
					else
						return false
					end
				end)
			local g = (meta:get_float("growth") or 0)
			+ math_sqrt(d * w) * math_random()
			if g >= 5000 then
				meta:from_table({})
				local place = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
				return minetest.place_schematic(place, nodecore.tree_schematic,
					"random", {}, false)
			end
			meta:set_float("growth", g)
		end
	})
