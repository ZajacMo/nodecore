-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local overlay = ""
for i = 0, 31 do
	overlay = overlay .. ":0," .. (i * 16) .. "=nc_terrain_cobble.png"
	.. ":0," .. (i * 16) .. "=nc_api_loose.png"
end

local amalgam = modname .. ":amalgam"
local lavasrc = modname .. ":lava_source"

minetest.register_node(amalgam, {
		description = "Amalgamation",
		tiles = {{
				name = "[combine:16x512:0,0=nc_terrain_lava.png" .. overlay,
				animation = {
					["type"] = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 8
				}
		}},
		paramtype = "light",
		light_source = 3,
		groups = {
			crumbly = 2,
			falling_repose = 3,
			igniter = 1,
			stack_as_node = 1
		},
		crush_damage = 2,
		stack_max = 1,
		sounds = nodecore.sounds("nc_terrain_chompy")
	})

nodecore.register_limited_abm({
		label = "Quench Lava to Amalgam",
		interval = 1,
		chance = 2,
		nodenames = {modname .. ":lava_source"},
		neighbors = {"group:coolant"},
		action = function(pos)
			return nodecore.set_loud(pos, {name = amalgam})
		end
	})

nodecore.register_limited_abm({
		label = "Melt Amalgam to Lava",
		interval = 1,
		chance = 2,
		nodenames = {amalgam},
		action = function(pos)
			if nodecore.quenched(pos) then return end
			return nodecore.set_loud(pos, {name = lavasrc})
		end
	})

nodecore.register_aism({
		label = "Amalgam Stack Melting",
		interval = 1,
		chance = 2,
		itemnames = {amalgam},
		action = function(stack, data)
			if nodecore.quenched(data.pos) then return end
			if stack:get_count() == 1 and data.node then
				local def = minetest.registered_nodes[data.node.name]
				if def and def.groups and def.groups.is_stack_only then
					nodecore.set_loud(data.pos, {name = lavasrc})
					stack:take_item(1)
					return stack
				end
			end
			for rel in nodecore.settlescan() do
				local p = vector.add(data.pos, rel)
				if nodecore.buildable_to(p) then
					nodecore.set_loud(p, {name = lavasrc})
					stack:take_item(1)
					return stack
				end
			end
		end
	})
