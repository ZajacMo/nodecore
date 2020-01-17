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

			minetest.set_node(pos, {name = epname})
			nodecore.node_sound(pos, "place")

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
				minetest.set_node(pos, {name = modname .. ":root"})
				minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z},
					{name = modname .. ":tree_bud", param2 = 1})
				local sub = minetest.get_meta(pos)
				sub:set_float("treegrowqty", data.total - sproutcost)
				sub:set_float("treegrowtime", nodecore.gametime)
				return
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

local function leafbud(pos, dx, dy, dz, param2)
	if param2 <= 1 then
		if 240 < math_random(0, 255) then return end
		local npos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
		if nodecore.buildable_to(npos) then
			return minetest.set_node(npos, nodecore.calc_leaves(npos))
		end
	end
	local npos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	if nodecore.buildable_to(npos) then
		return minetest.set_node(npos, {name = modname .. ":leaves_bud", param2 = param2})
	end
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
		soakrate = function(pos, node)
			if node and node.name == modname .. ":root" then
				return nodecore.tree_soil_rate(pos)
			end
			local bpos = {x = pos.x, y = pos.y, z = pos.z}
			for _ = 1, #nodecore.tree_params do
				bpos.y = bpos.y - 1
				node = minetest.get_node(bpos)
				if node.name == "ignore" then
					return
				elseif node.name == modname .. ":root" then
					return nodecore.tree_soil_rate(bpos)
				elseif node.name ~= modname .. ":tree" then
					minetest.set_node(pos, {name = modname .. ":tree"})
					return false
				end
			end
		end,
		soakcheck = function(data, pos, node)
			if data.total < trunkcost then return end

			local tp = nodecore.tree_params[node.param2]
			if not tp then return minetest.remove_node(pos) end

			minetest.set_node(pos, {name = modname .. ":tree"})

			local param2 = node.param2 + 1
			tp = nodecore.tree_params[param2]
			if not tp then return minetest.remove_node(pos) end
			while tp.prob and (tp.prob < math_random(0, 255)) do
				param2 = param2 + 1
				tp = nodecore.tree_params[param2]
				if not tp then return minetest.remove_node(pos) end
			end

			local apos = {x = pos.x, y = pos.y + 1, z = pos.z}
			if tp.leaves then
				leafbud(apos, 1, 0, 0, tp.leaves + 1)
				leafbud(apos, -1, 0, 0, tp.leaves + 1)
				leafbud(apos, 0, 0, 1, tp.leaves)
				leafbud(apos, 0, 0, -1, tp.leaves)
			end

			if tp.notrunk then
				minetest.set_node(apos, {
						name = modname .. ":leaves_bud",
						param2 = tp.leaves
					})
			else
				minetest.set_node(apos, {
						name = modname .. ":tree_bud",
						param2 = param2
					})
				local sub = minetest.get_meta(apos)
				sub:set_float("treegrowqty", data.total - trunkcost)
				sub:set_float("treegrowtime", nodecore.gametime)
				return false
			end
		end
	})

nodecore.register_limited_abm({
		label = "Tree Leaves Growth",
		nodenames = {modname .. ":leaves_bud"},
		interval = 10,
		chance = 10,
		limited_max = 100,
		limited_alert = 1000,
		action = function(pos, node)
			minetest.set_node(pos, nodecore.calc_leaves(pos))
			if node.param2 <= 1 then
				return
			elseif node.param2 == 2 then
				leafbud(pos, 1, 0, 0, 1)
				leafbud(pos, -1, 0, 0, 1)
			elseif node.param2 == 3 then
				leafbud(pos, 0, 0, 1, 1)
				leafbud(pos, 0, 0, -1, 1)
			else
				leafbud(pos, 1, 0, 0, 3)
				leafbud(pos, -1, 0, 0, 3)
				leafbud(pos, 0, 0, 1, 2)
				leafbud(pos, 0, 0, -1, 2)
				if node.param2 >= 6 then
					leafbud(pos, 0, 1, 0, node.param2 - 4)
				end
			end
		end
	})

minetest.register_chatcommand("growtrees", {
		description = "Accelerate growth of nearby trees",
		privs = {["debug"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			for _, p in pairs(nodecore.find_nodes_around(pos,
					{epname, modname .. ":tree_bud"}, 5)) do
				local r = nodecore.tree_growth_rate(p)
				if r and r > 0 then
					local meta = minetest.get_meta(p)
					meta:set_float("eggcornqty", 10000)
					meta:set_float("treegrowqty", 10000)
					minetest.chat_send_player(pname, "boosted "
						.. minetest.get_node(p).name
						.. " at " .. minetest.pos_to_string(p))
				end
			end
		end
	})
