-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local epname = modname .. ":eggcorn_planted"

minetest.register_node(modname .. ":eggcorn", {
		description = "Eggcorn",
		drawtype = "plantlike",
		paramtype = "light",
		visual_scale = 0.5,
		wield_scale = {x = 0.75, y = 0.75, z = 1.5},
		collision_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		selection_box = nodecore.fixedbox(-3/16, -0.5, -3/16, 3/16, 0, 3/16),
		inventory_image = "[combine:24x24:4,4=" .. modname
		.. "_eggcorn.png\\^[resize\\:16x16",
		tiles = {modname .. "_eggcorn.png"},
		groups = {
			snappy = 1,
			flammable = 3,
			attached_node = 1,
		},
		node_placement_prediction = "nc_items:stack",
		place_as_item = true,
		sounds = nodecore.sounds("nc_tree_corny")
	})

local function soilboost(pos, name)
	local def = minetest.registered_items[name]
	local soil = def.groups.soil or 0
	if soil > 2 then
		nodecore.soaking_abm_push(pos, "eggcorn", (soil - 2) * 500)
		nodecore.soaking_particles(pos, (soil - 2) * 10,
			0.5, .45, modname .. ":leaves_bud")
	end
end
nodecore.register_item_entity_step(function(self)
		if self.itemstring ~= modname .. ":eggcorn" then
			return
		end

		local pos = self.object:get_pos()
		if not pos then return end

		local curnode = minetest.get_node(pos)
		if minetest.get_item_group(curnode.name, "dirt_loose") < 1 then
			return
		end

		nodecore.set_loud(pos, {name = epname})
		self.itemstring = ""
		self.object:remove()

		soilboost(pos, curnode.name)
	end)
nodecore.register_craft({
		label = "eggcorn planting",
		action = "stackapply",
		wield = {groups = {dirt_loose = true}},
		consumewield = 1,
		indexkeys = {modname .. ":eggcorn"},
		nodes = {{match = modname .. ":eggcorn", replace = epname}},
		after = function(pos, data)
			soilboost(pos, data.wield:get_name())
		end
	})

minetest.register_abm({
		label = "legacy eggcorn node conversion",
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

local ldname = "nc_terrain:dirt_loose"
local epdef = nodecore.underride({
		description = "Sprout",
		drawtype = "plantlike_rooted",
		falling_visual = "nc_terrain:dirt_loose",
		special_tiles = {modname .. "_eggcorn_planted.png"},
		drop = ldname,
		no_self_repack = true,
		groups = {grassable = 0}
	}, minetest.registered_items[ldname] or {})
epdef.groups.soil = nil
minetest.register_node(epname, epdef)

minetest.register_node(modname .. ":tree_bud", {
		description = "Growing Tree Trunk",
		tiles = {
			modname .. "_bud_top.png",
			modname .. "_tree_top.png",
			modname .. "_bud_side.png"
		},
		groups = {
			choppy = 2,
			flammable = 12,
			fire_fuel = 6,
			falling_node = 1,
			scaling_time = 80
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_tree_woody"),
		drop_in_place = modname .. ":tree"
	})

local function fade(txr)
	return txr .. "^[multiply:#a0a0a0^" .. txr
end

minetest.register_node(modname .. ":leaves_bud", {
		description = "Growing Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {fade(modname .. "_leaves.png^" .. modname .. "_leaves_bud.png")},
		waving = 1,
		air_pass = true,
		groups = {
			canopy = 1,
			snappy = 1,
			flammable = 5,
			fire_fuel = 2,
			green = 4,
			scaling_time = 90,
			leaf_decay = 1
		},
		treeable_to = true,
		drop = "",
		after_dig_node = function(pos)
			return nodecore.leaf_decay(pos, nodecore.calc_leaves(pos))
		end,
		node_dig_prediction = "air",
		sounds = nodecore.sounds("nc_terrain_swishy"),
		leaf_decay_as = {
			name = modname .. ":leaves",
			param2 = 0
		}
	})
