-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "mix concrete (fail)",
		action = "pummel",
		priority = 2,
		toolgroups = {thumpy = 1},
		normal = {y = 1},
		nodes = {
			{
				match = {groups = {gravel = true}}
			},
			{
				x = 1,
				y = -1,
				match = {buildable_to = true}
			},
			{
				y = -1,
				match = "nc_fire:ash",
				replace = "air"
			}
		},
		after = function(pos)
			nodecore.item_disperse(pos, "nc_fire:lump_ash", 8)
		end
	})

nodecore.register_craft({
		label = "mix concrete",
		action = "pummel",
		priority = 1,
		toolgroups = {thumpy = 1},
		normal = {y = 1},
		nodes = {
			{
				match = {groups = {gravel = true}},
				replace = "air"
			},
			{
				y = -1,
				match = "nc_fire:ash",
				replace = modname .. ":aggregate"
			}
		}
	})

local flow = modname .. ":wet_flowing"
local src = modname .. ":wet_source"

nodecore.register_limited_abm({
		label = "Aggregate Wettening",
		interval = 1,
		chance = 2,
		limited_max = 100,
		nodenames = {modname .. ":aggregate"},
		neighbors = {"group:water"},
		action = function(pos)
			nodecore.set_loud(pos, {name = src})
		end
	})

nodecore.register_aism({
		label = "Aggregate Stack Wettening",
		interval = 1,
		chance = 2,
		itemnames = {modname .. ":aggregate"},
		action = function(stack, data)
			local found = minetest.find_node_near(data.pos, 1, {"group:water"})
			if not found then return end
			if stack:get_count() == 1 and data.node then
				local def = minetest.registered_nodes[data.node.name]
				if def and def.groups and def.groups.is_stack_only then
					found = data.pos
				end
			end
			nodecore.set_loud(found, {name = src})
			stack:take_item(1)
			return stack
		end
	})

nodecore.register_limited_abm({
		label = "Aggregate Wandering",
		interval = 4,
		chance = 2,
		limited_max = 100,
		nodenames = {src},
		neighbors = {flow},
		action = function(pos, node)
			local meta = minetest.get_meta(pos)
			local gen = meta:get_int("agggen")
			if gen >= 8 and math_random(1, 2) == 1 then
				nodecore.witness({x = pos.x, y = pos.y + 0.5, z = pos.z},
				"aggregate to cobble")
				return nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			end
			local miny = pos.y
			local found = {}
			nodecore.scan_flood(pos, 2, function(p)
					local nn = minetest.get_node(p).name
					if nn == src then return end
					if nn ~= flow then return false end
					if p.y > miny then return end
					if p.y == miny then
						found[#found + 1] = p
						return
					end
					miny = p.y
					found = {p}
				end)
			if #found < 1 then return end
			local np = nodecore.pickrand(found)
			nodecore.set_loud(np, node)
			minetest.get_meta(np):set_int("agggen", gen + 1)
			minetest.set_node(pos, {name = flow, param2 = 7})
		end
	})

nodecore.register_limited_abm({
		label = "Aggregate Sink/Disperse",
		interval = 4,
		chance = 2,
		limited_max = 100,
		nodenames = {src},
		neighbors = {"group:water"},
		action = function(pos, node)
			local waters = #nodecore.find_nodes_around(pos, "group:water") - 3
			local rnd = math_random() * 20
			if rnd * rnd < waters then
				nodecore.set_loud(pos, {name = "nc_terrain:gravel"})
				return nodecore.fallcheck(pos)
			end

			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = minetest.get_node(below)
			if bnode.name == "ignore" then return end
			local bdef = minetest.registered_nodes[bnode.name] or {}
			if bdef.groups and bdef.groups.water then
				nodecore.set_loud(below, node)
				nodecore.set_loud(pos, bnode)
				return
			end
		end
	})

nodecore.register_craft({
		label = "aggregate curing",
		action = "cook",
		duration = 300,
		cookfx = {smoke = 0.05},
		check = function(pos)
			return not minetest.find_node_near(pos, 1, {flow, "group:water"})
		end,
		nodes = {
			{
				match = src,
				replace = "nc_terrain:stone"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {src}})
