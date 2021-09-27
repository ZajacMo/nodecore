-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.dungeon_bricks()
	return {
		fill = "nc_terrain:cobble",
		brick = modname .. ":bricks_stone",
		bonded = modname .. ":bricks_stone_bonded"
	}
end

nodecore.register_dungeongen({
		label = "dungeon concrete/bricks",
		priority = -100,
		func = function(pos, _, rng)
			local profile = nodecore.dungeon_bricks(pos, rng)
			if rng(1, 4) ~= 1 then
				return profile.fill and
				minetest.set_node(pos, {name = profile.fill})
			end
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = minetest.get_node(below)
			local bdef = minetest.registered_nodes[bnode.name] or {}
			return minetest.set_node(pos, {name = (rng(1, 10) <=
						(bdef.walkable and 9 or 2)
						and profile.brick
						or profile.bonded)})
		end
	})
