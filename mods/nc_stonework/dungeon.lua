-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local mapperlin
minetest.after(0, function() mapperlin = minetest.get_perlin(45821, 1, 0, 1) end)

nodecore.register_dungeongen({
		label = "dungeon concrete/bricks",
		priority = -100,
		func = function(pos)
			local rng = nodecore.seeded_rng(mapperlin:get_3d(pos))
			if rng(1, 4) ~= 1 then return end
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = minetest.get_node(below)
			local bdef = minetest.registered_nodes[bnode.name] or {}
			return minetest.set_node(pos, {name = modname
					.. (rng(1, 10) <= (bdef.walkable and 9 or 2)
						and ":bricks_stone"
						or ":bricks_stone_bonded")})
		end
	})
