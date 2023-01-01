-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

-- Hotfix for items that are non-buildable and non-walkable
-- nodes falling through one another forever: if a node is not
-- buildable_to and not walkable, then it can "support" other
-- nodes that are also not buildable_to and not walkable, even
-- if they are not the exact same node (as per builtin).

local function nonbuildwalk(pos)
	local nn = minetest.get_node(pos).name
	local def = minetest.registered_nodes[nn]
	return def and not (def.buildable_to or def.walkable)
end

local oldcheck = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos, ...)
	if not nonbuildwalk(pos) then return oldcheck(pos, ...) end
	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	if nonbuildwalk(below) then return end
	return oldcheck(pos, ...)
end
