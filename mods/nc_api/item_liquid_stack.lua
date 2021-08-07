-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item(function(_, def)
		if def.liquidtype and def.liquidtype ~= "none" then
			def.groups = def.groups or {}
			def.groups.stack_as_node = def.groups.stack_as_node or 1
			def.stack_max = def.stack_max or 1
		end
	end)
