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

minetest.register_abm({
		label = "concrete wet",
		interval = 1,
		chance = 2,
		nodenames = {"group:concrete_powder"},
		neighbors = {"group:water"},
		action = function(pos, node)
			local wet = wetname(node.name)
			if not wet then return end
			nodecore.set_loud(pos, {name = wet})
			nodecore.dnt_set(pos, "fluidwander_concrete")
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
			nodecore.dnt_set(found, "fluidwander_concrete")
			stack:take_item(1)
			return stack
		end
	})

nodecore.register_fluidwandering(
	"concrete",
	{"group:concrete_source"},
	10,
	function(pos, node, gen)
		local def = concdef(node.name)
		if gen < 8 or math_random(1, 2) == 1 then return end
		nodecore.set_loud(pos, {name = def.to_crude})
		nodecore.witness({
				x = pos.x,
				y = pos.y + 0.5,
				z = pos.z
			},
			node.name .. " to " .. def.to_crude)
		return true
	end,
	1
)

minetest.register_abm({
		label = "concrete sink/disperse",
		interval = 4,
		chance = 2,
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
			local bname = minetest.get_node(below).name
			if bname == "ignore" then return end
			if minetest.get_item_group(bname, "water") > 0 then
				nodecore.set_loud(below, node)
				nodecore.remove_node(pos)
				return
			end
		end
	})

nodecore.register_soaking_abm({
		label = "wet concrete cure",
		interval = 5,
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
