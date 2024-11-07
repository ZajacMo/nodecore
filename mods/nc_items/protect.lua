-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local stacks_only = nc.group_expand("group:is_stack_only", true)

function nc.protection_exempt(pos)
	return stacks_only[core.get_node(pos).name]
end

core.after(0, function()
		local prot = core.is_protected
		function core.is_protected(pos, name, ...)
			if nc.protection_exempt(pos, name) then return false end
			return prot(pos, name, ...)
		end
	end)
