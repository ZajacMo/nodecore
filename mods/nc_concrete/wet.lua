-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function concdef(name)
	local def = minetest.registered_items[name]
	return def and def.concrete_def
end
local function wetname(name)
	local def = concdef(name)
	def = def and def.basename
	return def and (def .. "_wet_source")
end

nodecore.register_limited_abm({
		label = "concrete wet",
		interval = 1,
		chance = 2,
		limited_max = 100,
		nodenames = {"group:concrete_powder"},
		neighbors = {"group:water"},
		action = function(pos, node)
			local wet = wetname(node.name)
			if wet then return nodecore.set_loud(pos, {name = wet}) end
		end
	})

nodecore.register_aism({
		label = "concrete stack wet",
		interval = 1,
		chance = 2,
		itemnames = {"group:concrete_powder"},
		action = function(stack, data)
			local wet = wetname(stack:get_name())
			if not wet then return end
			local found = minetest.find_node_near(data.pos, 1, {"group:water"})
			if not found then return end
			if stack:get_count() == 1 and data.node then
				local ndef = minetest.registered_nodes[
				data.node.name]
				if ndef and ndef.groups and ndef.groups.is_stack_only then
					found = data.pos
				end
			end
			nodecore.set_loud(found, {name = wet})
			stack:take_item(1)
			return stack
		end
	})

nodecore.register_limited_abm({
		label = "concrete wander",
		interval = 4,
		chance = 2,
		limited_max = 100,
		nodenames = {"group:concrete_source"},
		neighbors = {"group:concrete_flow"},
		action = function(pos, node)
			local def = concdef(node.name)
			local meta = minetest.get_meta(pos)
			local gen = meta:get_int("agggen")
			if gen >= 8 and math_random(1, 2) == 1 then
				nodecore.witness({
						x = pos.x,
						y = pos.y + 0.5,
						z = pos.z
					},
					def.name .. " to " .. def.to_crude)
				return nodecore.set_loud(pos, {name = def.to_crude})
			end
			local miny = pos.y
			local found = {}
			nodecore.scan_flood(pos, 2, function(p)
					local nn = minetest.get_node(p).name
					if nn == node.name then return end
					if minetest.get_item_group(nn, "concrete_flow") < 1
					then return false end
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
			local flow = minetest.registered_items[node.name].liquid_alternative_flowing
			minetest.set_node(pos, {name = flow, param2 = 7})
		end
	})

nodecore.register_limited_abm({
		label = "concrete sink/disperse",
		interval = 4,
		chance = 2,
		limited_max = 100,
		nodenames = {"group:concrete_source"},
		neighbors = {"group:water"},
		action = function(pos, node)
			local def = concdef(node.name)
			local waters = #nodecore.find_nodes_around(pos, "group:water") - 3
			local rnd = math_random() * 20
			if rnd * rnd < waters then
				nodecore.set_loud(pos, {name = def.to_washed})
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

nodecore.register_soaking_abm({
		label = "wet concrete cure",
		interval = 5,
		chance = 2,
		limited_max = 100,
		nodenames = {"group:concrete_source"},
		fieldname = "curing",
		soakrate = function(pos)
			if minetest.find_node_near(pos,
				1, {"group:concrete_flow", "group:water"}) then
				return false
			end
			local found = nodecore.find_nodes_around(pos, "group:igniter", 1)
			return #found + 1
		end,
		soakcheck = function(data, pos, node)
			if data.total < 40 then
				nodecore.smokefx(pos, 5, data.rate)
				return
			end
			local def = concdef(node.name)
			nodecore.set_loud(pos, {name = def.to_molded})
			return false
		end
	})
