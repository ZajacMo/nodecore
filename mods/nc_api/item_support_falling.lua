-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local csff = core.check_single_for_falling
function core.check_single_for_falling(pos, ...)
	local gnon = core.get_node_or_nil
	function core.get_node_or_nil(p)
		local n = gnon(p)
		if not n then return n end
		local def = core.registered_nodes[n.name]
		if not def then return n end
		return (not (def and def.groups and def.groups.support_falling)) and n or nil
	end
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name] or {}
	local function helper(fell, ...)
		core.get_node_or_nil = gnon
		if fell then
			if def.on_node_fallen then
				local ret = def.on_node_fallen(pos, node)
				if ret ~= nil then return ret, ... end
			end
		elseif def.on_falling_check then
			return def.on_falling_check(pos, node)
		end
		return fell, ...
	end
	return helper(csff(pos, ...))
end
