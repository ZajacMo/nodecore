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
		inventory_image = modname .. "_eggcorn.png",
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 1,
			flammable = 3,
			falling_repose = 1
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

nodecore.register_limited_abm({
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
