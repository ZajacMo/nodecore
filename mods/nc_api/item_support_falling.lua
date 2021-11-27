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
	local function helper(fell, ...)
		minetest.get_node_or_nil = gnon
		if not fell then
			local node = minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name] or {}
			if def.on_falling_check then
				return def.on_falling_check(pos, node)
			end
		end
		return fell, ...
	end
	return helper(csff(pos, ...))
end
