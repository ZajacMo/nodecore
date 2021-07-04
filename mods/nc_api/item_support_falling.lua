-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local csff = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos, ...)
	local gnon = minetest.get_node_or_nil
	function minetest.get_node_or_nil(p)
		local n = gnon(p)
		if not n then return n end
		local def = minetest.registered_nodes[n.name]
		if not def then return n end
		return (not (def and def.groups and def.groups.support_falling)) and n or nil
	end
	local function helper(...)
		minetest.get_node_or_nil = gnon
		return ...
	end
	return helper(csff(pos, ...))
end
