-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local cob = ""
local loose = ""
for i = 0, 31 do
	cob = cob .. ":0," .. (i * 16) .. "=nc_terrain_cobble.png"
	loose = loose .. ":0," .. (i * 16) .. "=nc_api_loose.png"
end
local function tile(suff)
	return {
		name = "[combine:16x512:0,0=nc_terrain_lava.png" .. cob .. suff,
		animation = {
			["type"] = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 8
		}
	}
end

local amalgam = modname .. ":amalgam"
local lavasrc = "nc_terrain:lava_source"

minetest.register_node(amalgam, {
		description = "Amalgamation",
		old_names = {"nc_terrain:amalgam"},
		tiles = {tile("")},
		paramtype = "light",
		light_source = 3,
		stack_max = 1,
		groups = {
			cracky = 1,
			igniter = 1,
			stack_as_node = 1,
			amalgam = 1,
			cobbley = 1
		},
		alternate_loose = {
			tiles = {tile(loose)},
			repack_level = 2,
			groups = {
				cracky = 0,
				crumbly = 2,
				falling_repose = 3
			},
			sounds = nodecore.sounds("nc_terrain_chompy")
		},
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony"),
	})

minetest.register_abm({
		label = "lava quench",
		interval = 1,
		chance = 2,
		nodenames = {lavasrc},
		neighbors = {"group:coolant"},
		action = function(pos)
			nodecore.sound_play("nc_api_craft_hiss", {gain = 0.25, pos = pos})
			nodecore.smokefx(pos, 0.05, 20)
			nodecore.dynamic_shade_add(pos, 1)
			return nodecore.set_loud(pos, {name = amalgam})
		end
	})

minetest.register_abm({
		label = "amalgam melt",
		interval = 1,
		chance = 2,
		nodenames = {"group:amalgam"},
		arealoaded = 1,
		action = function(pos)
			if nodecore.quenched(pos) then return end
			return nodecore.set_loud(pos, {name = lavasrc})
		end
	})

nodecore.register_aism({
		label = "amalgam stack melt",
		interval = 1,
		chance = 2,
		arealoaded = 1,
		itemnames = {"group:amalgam"},
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

nodecore.register_falling_node_step(function(self)
		if not (self.node and self.node.name) then return end
		if minetest.get_item_group(self.node.name, "amalgam") <= 0 then return end

		local pos = self.object:get_pos()

		if (not pos)
		or nodecore.quenched(pos)
		or not nodecore.buildable_to(pos) then return end

		nodecore.set_loud(pos, {name = lavasrc})
		self.object:remove()

		return true
	end)
