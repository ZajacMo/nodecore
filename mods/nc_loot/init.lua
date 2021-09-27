-- LUALOCALS < ---------------------------------------------------------
local ItemStack, io, ipairs, math, minetest, nodecore, pairs, tonumber
    = ItemStack, io, ipairs, math, minetest, nodecore, pairs, tonumber
local io_open, math_floor, math_log
    = io.open, math.floor, math.log
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local loottable = {}
do
	local ltcsv = io_open(minetest.get_modpath(minetest.get_current_modname())
		.. "/loot.csv", "r")
	local cols = ltcsv:read("*l"):split(",")
	while true do
		local str = ltcsv:read("*l")
		if not str then break end
		local data = str:split(",")
		local row = {}
		for i, k in ipairs(cols) do
			row[k] = tonumber(data[i]) or data[i]
		end
		loottable[#loottable + 1] = row
	end
end

local mapperlin
minetest.after(0, function() mapperlin = minetest.get_perlin(432, 1, 0, 1) end)

local function lootstack(pos, rng)
	local loot = nodecore.pickrand(loottable,
		function(t) return pos.y <= t.depth and t.prob or 0 end,
		rng)
	local def = minetest.registered_items[loot.item]
	if not def then return end
	local stack = ItemStack(loot.item)
	if def.type == "tool" then
		stack:set_wear(rng(20000, 50000))
	elseif def.stack_max > 1 then
		local qty = math_floor(nodecore.exporand(loot.qty / 10, rng))
		if qty < 1 then qty = 1 elseif qty > def.stack_max then qty = def.stack_max end
		stack:set_count(qty)
	end
	return stack
end

local cobbles = {["nc_terrain:cobble"] = true}
local cobblist = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.dungeon_mapgen then
				cobbles[k] = true
			end
		end
		for k in pairs(cobbles) do
			cobblist[#cobblist + 1] = k
		end
	end)

local function addloot(pos, height)
	local rng = nodecore.seeded_rng(mapperlin:get_3d(pos))
	if rng(1, 5) == 1 and #nodecore.find_nodes_around(pos, cobblist, {1, 0, 1}) > 0 then
		local max = nodecore.exporand(2, rng)
		if max < 1 then max = 1 elseif max > height then max = height end
		for _ = 1, max do
			minetest.set_node(pos, {name = "nc_woodwork:shelf"})
			nodecore.stack_set(pos, lootstack(pos, rng))
			pos.y = pos.y + 1
		end
		return
	end
	minetest.set_node(pos, {name = "nc_items:stack"})
	nodecore.stack_set(pos, lootstack(pos, rng))
	nodecore.stack_node_sounds_except[minetest.hash_node_position(pos)] = true
end

nodecore.register_dungeongen({
		label = "dungeon loot",
		priority = 100,
		func = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if minetest.get_node(above).name ~= "air" then return end
			local rand = mapperlin:get_3d(pos)
			rand = rand - math_floor(rand)
			local prob = 0.1
			if pos.y < -128 then
				prob = prob * math_log(pos.y / -64) / math_log(2)
			end
			if rand > prob then return end
			for dy = 2, 8 do
				local p = {x = pos.x, y = pos.y + dy, z = pos.z}
				local nn = minetest.get_node(p).name
				if cobbles[nn] then
					return #nodecore.find_nodes_around(pos,
						{"air"}, {1, 0, 1}) > 0
					or addloot(above, dy - 2)
				end
				if nn ~= "air" then return end
			end
			if pos.y > -64 then return end
			addloot(above, 8)
		end
	})
