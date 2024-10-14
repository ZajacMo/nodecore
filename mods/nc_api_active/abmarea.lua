-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local oldreg = core.register_abm
function core.register_abm(def)
	if def.arealoaded then
		local dist = def.arealoaded
		local oldact = def.action
		def.action = function(pos, node, ...)
			if nc.near_unloaded(pos, node, dist) then return end
			return oldact(pos, node, ...)
		end
	end
	return oldreg(def)
end
