-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_random, table_concat
    = math.random, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function growparticles(pos, rate, width)
	local zero = {x = 0, y = 0, z = 0}
	nodecore.digparticles(minetest.registered_items[modname .. ":leaves_bud"],
		{
			amount = rate,
			time = 10,
			minpos = {
				x = pos.x - width,
				y = pos.y + 33/64,
				z = pos.z - width
			},
			maxpos = {
				x = pos.x + width,
				y = pos.y + 33/64,
				z = pos.z + width
			},
			minvel = zero,
			maxvel = zero,
			minexptime = 0.25,
			maxexptime = 1,
			minsize = 3 * width,
			maxsize = 9 * width,
		})
end

local sproutcost = 2000
nodecore.register_soaking_abm({
		label = "eggcorn sprout",
		fieldname = "eggcorn",
		nodenames = {modname .. ":eggcorn_planted"},
		interval = 10,
		soakrate = nodecore.tree_growth_rate,
		soakcheck = function(data, pos)
			if nodecore.near_unloaded(pos) then return end
			if data.total >= sproutcost then
				nodecore.node_sound(pos, "dig")
				nodecore.set_loud(pos, {name = modname .. ":root"})
				local apos = {x = pos.x, y = pos.y + 1, z = pos.z}
				nodecore.witness(apos, "tree growth")
				nodecore.set_loud(apos,
					{name = modname .. ":tree_bud", param2 = 1})
				return nodecore.soaking_abm_push(apos,
					"treegrow", data.total - sproutcost)
			end
			return growparticles(pos, data.rate, 0.2)
		end
	})

local function leafbud(pos, dx, dy, dz, param2, surplus, rate)
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
	minetest.get_meta(npos):set_float("growrate", rate)
	return nodecore.soaking_abm_push(npos, "leafgrow", surplus)
end

local trunkcost = 1000
nodecore.register_soaking_abm({
		label = "tree trunk grow",
		fieldname = "treegrow",
		nodenames = {modname .. ":tree_bud"},
		interval = 10,
		soakrate = nodecore.tree_trunk_growth_rate,
		soakcheck = function(data, pos, node)
			if nodecore.near_unloaded(pos) then return end
			if data.total < trunkcost then
				return growparticles(pos, data.rate, 0.45)
			end

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
				leafbud(apos, 1, 0, 0, tp.leaves + 1, surplus, data.rate)
				leafbud(apos, -1, 0, 0, tp.leaves + 1, surplus, data.rate)
				leafbud(apos, 0, 0, 1, tp.leaves, surplus, data.rate)
				leafbud(apos, 0, 0, -1, tp.leaves, surplus, data.rate)
			end

			if tp.notrunk then
				leafbud(apos, 0, 0, 0, tp.leaves, surplus, data.rate)
			else
				nodecore.witness(apos, "tree growth")
				nodecore.set_loud(apos, {
						name = modname .. ":tree_bud",
						param2 = param2
					})
				nodecore.soaking_abm_push(apos,
					"treegrow", surplus)
			end
		end
	})

local leafcost = trunkcost
nodecore.register_soaking_abm({
		label = "tree leaves grow",
		nodenames = {modname .. ":leaves_bud"},
		fieldname = "leafgrow",
		interval = 10,
		soakrate = function(pos)
			local rate = minetest.get_meta(pos):get_float("growrate") or 0
			return rate and rate ~= 0 and rate or 10
		end,
		soakcheck = function(data, pos, node)
			if nodecore.near_unloaded(pos) then return end
			if data.total < leafcost then return end

			nodecore.set_loud(pos, nodecore.calc_leaves(pos))

			local surplus = data.total - leafcost
			if node.param2 <= 1 then
				return
			elseif node.param2 == 2 then
				leafbud(pos, 1, 0, 0, 1, surplus, data.rate)
				leafbud(pos, -1, 0, 0, 1, surplus, data.rate)
			elseif node.param2 == 3 then
				leafbud(pos, 0, 0, 1, 1, surplus, data.rate)
				leafbud(pos, 0, 0, -1, 1, surplus, data.rate)
			else
				leafbud(pos, 1, 0, 0, 3, surplus, data.rate)
				leafbud(pos, -1, 0, 0, 3, surplus, data.rate)
				leafbud(pos, 0, 0, 1, 2, surplus, data.rate)
				leafbud(pos, 0, 0, -1, 2, surplus, data.rate)
				if node.param2 >= 6 then
					leafbud(pos, 0, 1, 0, node.param2 - 4, surplus, data.rate)
				end
			end
		end
	})

local growtreedata = {
	[modname .. ":eggcorn_planted"] = {
		r = nodecore.tree_growth_rate,
		f = "eggcorn"
	},
	[modname .. ":tree_bud"] = {
		r = nodecore.tree_trunk_growth_rate,
		f = "treegrow"
	},
	[modname .. ":leaves_bud"] = {
		r = function() return 1 end,
		f = "leafgrow"
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
			local grew = {}
			for _, p in pairs(nodecore.find_nodes_around(pos, spec, 5)) do
				local nn = minetest.get_node(p).name
				local data = growtreedata[nn]
				local r = data.r(p)
				if r and r > 0 then
					nodecore.soaking_abm_push(p, data.f, 100000)
					grew[#grew + 1] = nn .. " at " .. minetest.pos_to_string(p)
				end
			end
			return true, table_concat(grew, "\n")
		end
	})
