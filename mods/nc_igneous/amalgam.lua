-- LUALOCALS < ---------------------------------------------------------
local core, nc, vector
    = core, nc, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local cob = ""
local loose = ""
for i = 0, 31 do
	cob = cob .. ":0," .. (i * 16) .. "=(nc_terrain_cobble.png\\^[resize\\:16x16)"
	loose = loose .. ":0," .. (i * 16) .. "=(nc_api_loose.png\\^[resize\\:16x16)"
end
local function tile(suff)
	return {
		name = "[combine:16x512:0,0=nc_terrain_lava.png\\^[resize\\:16x512" .. cob .. suff,
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

core.register_node(amalgam, {
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
			sounds = nc.sounds("nc_terrain_chompy")
		},
		crush_damage = 2,
		sounds = nc.sounds("nc_terrain_stony"),
		mapcolor = {r = 238, g = 76, b = 0},
	})

core.register_abm({
		label = "lava quench",
		interval = 1,
		chance = 2,
		nodenames = {lavasrc},
		neighbors = {"group:coolant"},
		action = function(pos)
			nc.sound_play("nc_api_craft_hiss", {gain = 0.25, pos = pos})
			nc.smokeburst(pos)
			nc.dynamic_shade_add(pos, 1)
			return nc.set_loud(pos, {name = amalgam})
		end
	})

core.register_abm({
		label = "amalgam melt",
		interval = 1,
		chance = 2,
		nodenames = {"group:amalgam"},
		arealoaded = 1,
		action = function(pos)
			if nc.quenched(pos) then return end
			return nc.set_loud(pos, {name = lavasrc})
		end
	})

nc.register_aism({
		label = "amalgam stack melt",
		interval = 1,
		chance = 2,
		arealoaded = 1,
		itemnames = {"group:amalgam"},
		action = function(stack, data)
			if nc.quenched(data.pos) then return end
			if stack:get_count() == 1 and data.node then
				local def = core.registered_nodes[data.node.name]
				if def and def.groups and def.groups.is_stack_only then
					nc.set_loud(data.pos, {name = lavasrc})
					stack:take_item(1)
					return stack
				end
			end
			for rel in nc.settlescan() do
				local p = vector.add(data.pos, rel)
				if nc.buildable_to(p) then
					nc.set_loud(p, {name = lavasrc})
					stack:take_item(1)
					return stack
				end
			end
		end
	})
