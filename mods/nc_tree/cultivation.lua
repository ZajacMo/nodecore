-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
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
		tiles = {modname .. "_eggcorn.png"},
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
			local def = minetest.registered_items[stack:get_name()]
			if (not def) or (not def.groups) or (not def.groups.dirt_loose) then return end

			nodecore.set_loud(pos, {name = epname})

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

local epdef = nodecore.underride({
		drop = ldname,
		no_self_repack = true
	}, minetest.registered_items[ldname] or {})
epdef.groups.soil = nil
minetest.register_node(epname, epdef)

local sproutcost = 2000
nodecore.register_soaking_abm({
		label = "EggCorn Growing",
		fieldname = "eggcorn",
		nodenames = {epname},
		interval = 10,
		chance = 1,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = nodecore.tree_growth_rate,
		soakcheck = function(data, pos)
			if data.total >= sproutcost then
				nodecore.node_sound(pos, "dig")
				nodecore.set_loud(pos, {name = modname .. ":root"})
				local apos = {x = pos.x, y = pos.y + 1, z = pos.z}
				nodecore.witness(apos, "grow tree")
				nodecore.set_loud(apos,
					{name = modname .. ":tree_bud", param2 = 1})
				return nodecore.soaking_abm_push(apos,
					"treegrow", data.total - sproutcost)
			end
			local zero = {x = 0, y = 0, z = 0}
			nodecore.digparticles(minetest.registered_items[modname .. ":leaves"],
				{
					amount = data.rate,
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
		end
	})

local function leafbud(pos, dx, dy, dz, param2, surplus)
	local npos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	if not nodecore.buildable_to(npos) then
		local node = minetest.get_node(npos)
		if minetest.get_item_group(node.name, "canopy") == 0 or param2 < node.param2
		then return end
	end
	if param2 <= 1 then
		if 240 < math_random(0, 255) then return end
		return nodecore.set_loud(npos, nodecore.calc_leaves(npos))
	end
	nodecore.set_loud(npos, {name = modname .. ":leaves_bud", param2 = param2})
	return nodecore.soaking_abm_push(npos, "leafgrow", surplus)
end

local trunkcost = 500
nodecore.register_soaking_abm({
		label = "Tree Trunk Growth",
		fieldname = "treegrow",
		nodenames = {modname .. ":tree_bud"},
		interval = 10,
		chance = 1,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = nodecore.tree_trunk_growth_rate,
		soakcheck = function(data, pos, node)
			if data.total < trunkcost then return end

			local tp = nodecore.tree_params[node.param2]
			if not tp then return minetest.remove_node(pos) end

			minetest.set_node(pos, {name = modname .. ":tree"})

			local apos = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not nodecore.buildable_to(apos)
			and minetest.get_item_group(minetest.get_node(apos).name, "canopy") == 0
			then return end

			local param2 = node.param2 + 1
			tp = nodecore.tree_params[param2]
			if not tp then return minetest.remove_node(pos) end
			while tp.prob and (tp.prob < math_random(0, 255)) do
				param2 = param2 + 1
				tp = nodecore.tree_params[param2]
				if not tp then return minetest.remove_node(pos) end
			end

			local surplus = data.total - trunkcost
			if tp.leaves then
				leafbud(apos, 1, 0, 0, tp.leaves + 1, surplus)
				leafbud(apos, -1, 0, 0, tp.leaves + 1, surplus)
				leafbud(apos, 0, 0, 1, tp.leaves, surplus)
				leafbud(apos, 0, 0, -1, tp.leaves, surplus)
			end

			if tp.notrunk then
				nodecore.set_loud(apos, {
						name = modname .. ":leaves_bud",
						param2 = tp.leaves
					})
			else
				nodecore.witness(apos, "grow tree")
				nodecore.set_loud(apos, {
						name = modname .. ":tree_bud",
						param2 = param2
					})
				nodecore.soaking_abm_push(apos,
					"treegrow", surplus)
				return false
			end
		end
	})

local leafcost = trunkcost
nodecore.register_soaking_abm({
		label = "Tree Leaves Growth",
		nodenames = {modname .. ":leaves_bud"},
		fieldname = "leafgrow",
		interval = 10,
		chance = 1,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = function() return 10 end,
		soakcheck = function(data, pos, node)
			if data.total < leafcost then return end

			nodecore.set_loud(pos, nodecore.calc_leaves(pos))

			local surplus = data.total - leafcost
			if node.param2 <= 1 then
				return
			elseif node.param2 == 2 then
				leafbud(pos, 1, 0, 0, 1, surplus)
				leafbud(pos, -1, 0, 0, 1, surplus)
			elseif node.param2 == 3 then
				leafbud(pos, 0, 0, 1, 1, surplus)
				leafbud(pos, 0, 0, -1, 1, surplus)
			else
				leafbud(pos, 1, 0, 0, 3, surplus)
				leafbud(pos, -1, 0, 0, 3, surplus)
				leafbud(pos, 0, 0, 1, 2, surplus)
				leafbud(pos, 0, 0, -1, 2, surplus)
				if node.param2 >= 6 then
					leafbud(pos, 0, 1, 0, node.param2 - 4, surplus)
				end
			end
		end
	})

local growtreedata = {
	[epname] = {
		r = nodecore.tree_growth_rate,
		f = "eggcorn"
	},
	[modname .. ":tree_bud"] = {
		r = nodecore.tree_trunk_growth_rate,
		f = "treegrow"
	}
}
minetest.register_chatcommand("growtrees", {
		description = "Accelerate growth of nearby trees",
		privs = {["debug"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			local spec = {}
			for k in pairs(growtreedata) do spec[#spec + 1] = k end
			for _, p in pairs(nodecore.find_nodes_around(pos, spec, 5)) do
				local nn = minetest.get_node(p).name
				local data = growtreedata[nn]
				local r = data.r(p)
				if r and r > 0 then
					nodecore.soaking_abm_push(p, data.f, 100000)
					minetest.chat_send_player(pname, "boosted "
						.. nn .. " at " .. minetest.pos_to_string(p)) end
				end
			end
		})
