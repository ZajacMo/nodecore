-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function concdef(name)
	local def = core.registered_items[name]
	return def and def.concrete_def
end
local function wetname(name)
	local def = concdef(name)
	def = def and def.basename
	return def and (def .. "_wet_source")
end

function nc.concrete_wet_node(pos, node)
	node = node or core.get_node(pos)
	local wet = wetname(node.name)
	if not wet then return end
	nc.set_loud(pos, {name = wet})
	nc.fallcheck({x = pos.x, y = pos.y + 1, z = pos.z})
	nc.dnt_set(pos, "fluidwander_concrete")
	return true
end

core.register_abm({
		label = "concrete wet",
		interval = 1,
		chance = 2,
		nodenames = {"group:concrete_powder"},
		neighbors = {"group:water"},
		action = function(...)
			return nc.concrete_wet_node(...)
		end
	})

nc.register_aism({
		label = "concrete stack wet",
		interval = 1,
		chance = 2,
		itemnames = {"group:concrete_powder"},
		action = function(stack, data)
			local wet = wetname(stack:get_name())
			if not wet then return end
			local found = core.find_node_near(data.pos, 1, {"group:water"})
			if not found then return end
			if stack:get_count() == 1 and data.node then
				local ndef = core.registered_nodes[
				data.node.name]
				if ndef and ndef.groups and ndef.groups.is_stack_only then
					found = data.pos
				end
			end
			nc.set_loud(found, {name = wet})
			nc.dnt_set(found, "fluidwander_concrete")
			stack:take_item(1)
			return stack
		end
	})

nc.register_fluidwandering(
	"concrete",
	{"group:concrete_source"},
	10,
	function(pos, node, gen)
		local def = concdef(node.name)
		if gen < 8 or math_random(1, 2) == 1 then return end
		nc.set_loud(pos, {name = def.to_crude})
		nc.witness({
				x = pos.x,
				y = pos.y + 0.5,
				z = pos.z
			},
			node.name .. " to " .. def.to_crude)
		return true
	end,
	1
)

core.register_abm({
		label = "concrete sink/disperse",
		interval = 4,
		chance = 2,
		nodenames = {"group:concrete_source"},
		neighbors = {"group:water"},
		action = function(pos, node)
			local def = concdef(node.name)
			local waters = #nc.find_nodes_around(pos, "group:water") - 3
			local rnd = math_random() * 20
			if rnd * rnd < waters then
				nc.set_loud(pos, {name = def.to_washed})
				return nc.fallcheck(pos)
			end

			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bname = core.get_node(below).name
			if bname == "ignore" then return end
			if core.get_item_group(bname, "water") > 0 then
				nc.set_loud(below, node)
				nc.remove_node(pos)
				return
			end
		end
	})

nc.register_soaking_abm({
		label = "wet concrete cure",
		interval = 5,
		nodenames = {"group:concrete_source"},
		fieldname = "curing",
		arealoaded = 1,
		soakrate = function(pos)
			if core.find_node_near(pos,
				1, {"group:concrete_flow", "group:water"}) then
				return false
			end
			local found = nc.find_nodes_around(pos, "group:igniter", 1)
			return #found + 1
		end,
		soakcheck = function(data, pos, node)
			if data.total < 40 then
				nc.smokefx(pos, 5, data.rate)
				return
			end
			local def = concdef(node.name)
			nc.smokeburst(pos)
			nc.dynamic_shade_add(pos, 1)
			nc.set_loud(pos, {name = def.to_molded})
			return false
		end
	})
