-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

function nc.dungeon_bricks()
	return {
		fill = "nc_terrain:cobble",
		brick = modname .. ":bricks_stone",
		bonded = modname .. ":bricks_stone_bonded"
	}
end

nc.register_dungeongen({
		label = "dungeon concrete/bricks",
		priority = -100,
		func = function(pos, _, rng)
			local profile = nc.dungeon_bricks(pos, rng)
			if rng(1, 4) ~= 1 then
				return profile.fill and
				core.set_node(pos, {name = profile.fill})
			end
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = core.get_node(below)
			local bdef = core.registered_nodes[bnode.name] or {}
			if bdef.walkable then
				return core.set_node(pos, {name = (rng(1, 10) <= 9)
						and profile.brick or profile.bonded})
			end
			return core.set_node(pos, {name = (rng(1, 10) <= 3)
					and profile.bonded or "air"})
		end
	})
