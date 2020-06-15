-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local oldfunc = minetest.register_entity
function minetest.register_entity(name, def, ...)
	def.label = def.label or name
	return oldfunc(name, def, ...)
end
