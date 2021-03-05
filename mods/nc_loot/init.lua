-- LUALOCALS < ---------------------------------------------------------
local ItemStack, include, math, minetest, nodecore, pairs
    = ItemStack, include, math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local loottable = include("loottable")

local mapperlin
minetest.after(0, function() mapperlin = minetest.get_perlin(432, 1, 0, 1) end)
local function addloot(pos) -- (pos, height)
	local rng = nodecore.seeded_rng(mapperlin:get_3d(pos))
	local loot = nodecore.pickrand(loottable, function(t) return t.prob end, rng)
	local def = minetest.registered_items[loot.item]
	if not def then return end
	local stack = ItemStack(loot.item)
	if def.type == "tool" then
		stack:set_wear(rng(20000, 50000))
	elseif def.stack_max > 1 then
		local qty = math_floor(nodecore.exporand(loot.qty / 10, rng))
		if qty < 1 then qty = 1 end
		if qty > def.stack_max then qty = def.stack_max end
		stack:set_count(qty)
	end
	minetest.set_node(pos, {name = "nc_items:stack"})
	nodecore.stack_set(pos, stack)
end

local cobbles = {["nc_terrain:cobble"] = true}
for k, v in pairs(minetest.registered_nodes) do
	if v.groups and v.groups.dungeon_mapgen then
		cobbles[k] = true
	end
end

nodecore.register_dungeongen({
		label = "dungeon loot",
		func = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if minetest.get_node(above).name ~= "air" then return end
			local rand = mapperlin:get_3d(pos)
			rand = rand - math_floor(rand)
			if rand > 0.05 then return end
			for dy = 2, 16 do
				local p = {x = pos.x, y = pos.y + dy, z = pos.z}
				local nn = minetest.get_node(p).name
				if cobbles[nn] then return addloot(above, dy - 1) end
				if nn ~= "air" then return
				end
			end
		end
	})
