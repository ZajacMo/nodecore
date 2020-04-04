-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local epname = modname .. ":eggcorn_planted"

local function eggcorn_plant(pos, whom, stack)
	local def = minetest.registered_items[stack:get_name()]
	if (not def) or (not def.groups) or (not def.groups.dirt_loose) then return end

	nodecore.set_loud(pos, {name = epname, param2 = 16})

	if nodecore.player_stat_add then
		nodecore.player_stat_add(1, whom, "craft", "eggcorn planting")
	end
	minetest.log((whom and whom:get_player_name() or "unknown")
		.. " planted an eggcorn at " .. minetest.pos_to_string(pos))

	stack:set_count(stack:get_count() - 1)
	return stack
end

minetest.register_node(modname .. ":eggcorn", {
		description = "Eggcorn",
		drawtype = "mesh",
		mesh = "nc_tree_eggcorn.obj",
		paramtype = "light",
		collision_box = nodecore.fixedbox(-0.5, -0.5, -0.5, 0.5, 0.5, 0.5),
		selection_box = nodecore.fixedbox(-5/16, -0.5, -5/16, 5/16, 1/16, 5/16),
		tiles = {
			modname .. "_eggcorn_top.png",
			modname .. "_eggcorn_bottom.png",
			modname .. "_eggcorn_side.png"
		},
		groups = {
			snappy = 1,
			flammable = 3,
			falling_node = 1,
			falling_repose = 1
		},
		node_placement_prediction = "",
		sounds = nodecore.sounds("nc_tree_corny"),
		stack_rightclick = function(pos, _, whom, stack)
			if nodecore.stack_get(pos):get_count() ~= 1 then return end
			return eggcorn_plant(pos, whom, stack)
		end,
		on_rightclick = function(pos, _, whom, stack)
			return eggcorn_plant(pos, whom, stack)
		end
	})

nodecore.register_leaf_drops(function(_, node, list)
		list[#list + 1] = {
			name = modname .. ":eggcorn",
			prob = 0.05 * (node.param2 + 1)}
	end)

local ldname = "nc_terrain:dirt_loose"
local epdef = nodecore.underride({
		description = "Sprout",
		drawtype = "plantlike_rooted",
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

minetest.register_node(modname .. ":leaves_bud", {
		description = "Growing Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {modname .. "_leaves.png^" .. modname .. "_leaves_bud.png"},
		waving = 1,
		air_pass = true,
		groups = {
			canopy = 1,
			snappy = 1,
			flammable = 5,
			fire_fuel = 2,
			green = 4,
			scaling_time = 90
		},
		treeable_to = true,
		drop = "",
		after_dig_node = function(pos)
			return nodecore.leaf_decay(pos, nodecore.calc_leaves(pos))
		end,
		node_dig_prediction = "air",
		sounds = nodecore.sounds("nc_terrain_swishy")
	})
