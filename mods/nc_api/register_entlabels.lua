-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local oldfunc = core.register_entity
function core.register_entity(name, def, ...)
	def.label = def.label or name
	return oldfunc(name, def, ...)
end
