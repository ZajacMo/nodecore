-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_pow, math_random
    = math.pow, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local growdirs = nodecore.dirs()

local living = modname .. ":sponge_living"

nodecore.register_limited_abm({
		label = "Sponge Growth",
		interval = 10,
		chance = 1000,
		limited_max = 100,
		nodenames = {living},
		neighbors = {"group:water"},
		action = function(pos)
			local total = 0
			if nodecore.scan_flood(pos, 6,
				function(p, d)
					if d >= 6 then return true end
					if minetest.get_node(p).name ~= living then return false end
					total = total + 1
					if total >= 20 then return true end
				end
			) then return end

			pos = vector.add(pos, growdirs[math_random(1, #growdirs)])

			local node = minetest.get_node_or_nil(pos)
			local def = node and minetest.registered_nodes[node.name]
			local grp = def and def.groups and def.groups.water
			if (not grp) or (grp < 1) then return end

			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			node = minetest.get_node(below)
			if (math_random() > 0.1) or (node.name ~= living) then
				def = minetest.registered_nodes[node.name]
				grp = def and def.groups and def.groups.sand
				if (not grp) or (grp < 1) then return end
			end
			minetest.set_node(pos, {name = living})
		end
	})

-- A living sponge can be dug intact, RARELY, and ONLY if surrounded
-- on all sides and edges (X/Z plane) by other living sponges.

local digpos
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, ...)
	if (node and node.name) ~= living then
		return old_node_dig(pos, node, ...)
	end
	local function helper(...)
		digpos = nil
		return ...
	end
	digpos = pos
	return helper(old_node_dig(pos, node, ...))
end
local old_get_node_drops = minetest.get_node_drops
minetest.get_node_drops = function(...)
	local drops = old_get_node_drops(...)
	if not digpos then return drops end
	local neighbors = #nodecore.find_nodes_around(digpos, living)
	if neighbors >= 5 then
		local prob = math_pow(2, neighbors - 5) * 0.005
		if math_random() <= prob then return drops end
	end
	drops = drops or {}
	for k, v in pairs(drops) do
		v = ItemStack(v)
		if v:get_name() == living then
			v:set_name(modname .. ":sponge_wet")
		end
		drops[k] = v
	end
	return drops
end
