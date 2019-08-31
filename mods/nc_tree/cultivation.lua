-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random, math_sqrt
    = math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local ldname = "nc_terrain:dirt_loose"
local epname = modname .. ":eggcorn_planted"

minetest.register_node(modname .. ":eggcorn", {
		description = "Eggcorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		wield_scale = {x = 0.75, y = 0.75, z = 1.5},
		collision_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		selection_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		inventory_image = "[combine:24x24:4,4=" .. modname .. "_eggcorn.png",
		tiles = { modname .. "_eggcorn.png" },
		groups = {
			snappy = 1,
			flammable = 3,
			attached_node = 1,
		},
		node_placement_prediction = "",
		place_as_item = true,
		sounds = nodecore.sounds("nc_tree_corny"),
		stack_rightclick = function(pos, _, whom, stack)
			if nodecore.stack_get(pos):get_count() ~= 1 then return end
			if stack:get_name() ~= ldname then return end

			minetest.set_node(pos, {name = epname})
			nodecore.node_sound(pos, "place")

			if nodecore.player_stat_add then
				nodecore.player_stat_add(1, whom, "craft", "eggcorn planting")
			end
			minetest.log((whom and whom:get_player_name() or "unknown")
				.. " planted an eggcorn at " .. minetest.pos_to_string(pos))

			stack:set_count(stack:get_count() - 1)
			return stack
		end
	})

nodecore.register_limited_abm({
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":eggcorn"},
		action = function(pos)
			minetest.remove_node(pos)
			return nodecore.place_stack(pos, modname .. ":eggcorn")
		end
	})

nodecore.register_leaf_drops(function(_, node, list)
		list[#list + 1] = {
			name = "air",
			item = modname .. ":eggcorn",
			prob = 0.05 * (node.param2 + 1)}
	end)

minetest.register_node(epname, nodecore.underride({
			drop = ldname
		},
		minetest.registered_items[ldname] or {}))

nodecore.register_limited_abm({
		label = "EggCorn Growing",
		nodenames = {epname},
		interval = 10,
		chance = 1,
		action = function(pos)
			local meta = minetest.get_meta(pos)
			local d = 0
			local w = 1
			nodecore.scan_flood(pos, 3, function(p)
					local nn = minetest.get_node(p).name
					local def = minetest.registered_items[nn] or {}
					if not def.groups then
						return false
					end
					if def.groups.soil then
						d = d + def.groups.soil
						w = w + 0.2
					elseif def.groups.moist then
						w = w + def.groups.moist
						return false
					else
						return false
					end
				end)
			local rate = math_sqrt(d * w)
			local zero = {x = 0, y = 0, z = 0}
			nodecore.digparticles(minetest.registered_items[modname .. ":leaves"],
				{
					amount = rate,
					time = 10,
					minpos = {
						x = pos.x - 0.3,
						y = pos.y + 33/64,
						z = pos.z - 0.3
					},
					maxpos = {
						x = pos.x + 0.3,
						y = pos.y + 33/64,
						z= pos.z + 0.3
					},
					minvel = zero,
					maxvel = zero,
					minexptime = 0.1,
					maxexptime = 0.5,
					minsize = 1,
					maxsize = 3,
				})
			local g = meta:get_float("growth") or 0
			local now = minetest.get_gametime()
			local t = meta:get_float("start")
			t = t and t > 0 and t or now
			while t <= now do
				g = g + rate * math_random()
				t = t + 10
			end
			if g >= 5000 then
				meta:from_table({})
				local place = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
				return minetest.place_schematic(place, nodecore.tree_schematic,
					"random", {}, false)
			end
			meta:set_float("growth", g)
			meta:set_float("start", t)
		end
	})
