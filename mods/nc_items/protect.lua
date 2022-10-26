-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local stacks_only = nodecore.group_expand("group:is_stack_only", true)

function nodecore.protection_exempt(pos)
	return stacks_only[minetest.get_node(pos)]
end

minetest.after(0, function()
		local prot = minetest.is_protected
		function minetest.is_protected(pos, name, ...)
			if nodecore.protection_exempt(pos, name) then return false end
			return prot(pos, name, ...)
		end
	end)
